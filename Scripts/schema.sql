-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(255),
  referral_code VARCHAR(32) UNIQUE NOT NULL,
  credits DECIMAL(10, 2) DEFAULT 0,
  total_earned DECIMAL(10, 2) DEFAULT 0,
  profile_image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  is_active BOOLEAN DEFAULT TRUE
);

-- Create referrals table
CREATE TABLE IF NOT EXISTS referrals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  referred_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'pending', -- pending, completed, rejected
  bonus_credits DECIMAL(10, 2) DEFAULT 10,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  UNIQUE(referrer_id, referred_id)
);

-- Create transactions table
CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  referral_id UUID REFERENCES referrals(id) ON DELETE SET NULL,
  type VARCHAR(20) NOT NULL, -- earn, redeem, bonus, adjustment
  amount DECIMAL(10, 2) NOT NULL,
  description TEXT,
  status VARCHAR(20) DEFAULT 'completed', -- pending, completed, failed
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create credit_ledger table for audit trail
CREATE TABLE IF NOT EXISTS credit_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  transaction_id UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
  previous_balance DECIMAL(10, 2),
  new_balance DECIMAL(10, 2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_ledger ENABLE ROW LEVEL SECURITY;

-- Create indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_referral_code ON users(referral_code);
CREATE INDEX idx_referrals_referrer_id ON referrals(referrer_id);
CREATE INDEX idx_referrals_referred_id ON referrals(referred_id);
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_referral_id ON transactions(referral_id);
CREATE INDEX idx_credit_ledger_user_id ON credit_ledger(user_id);

-- RLS Policies for users table
CREATE POLICY "Users can read own profile" ON users
  FOR SELECT USING (auth.uid()::text = id::text);

CREATE POLICY "Users can read public referral data" ON users
  FOR SELECT USING (TRUE); -- Allow reading referral_code and stats

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid()::text = id::text);

-- RLS Policies for referrals table
CREATE POLICY "Users can read own referrals" ON referrals
  FOR SELECT USING (
    auth.uid()::text = referrer_id::text OR 
    auth.uid()::text = referred_id::text
  );

CREATE POLICY "Users can insert referrals" ON referrals
  FOR INSERT WITH CHECK (auth.uid()::text = referrer_id::text);

CREATE POLICY "Admins can update referrals" ON referrals
  FOR UPDATE USING (auth.uid()::text = referrer_id::text OR 
                    EXISTS (SELECT 1 FROM users WHERE id = auth.uid()::uuid AND email LIKE '%@admin%'));

-- RLS Policies for transactions table
CREATE POLICY "Users can read own transactions" ON transactions
  FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "System can insert transactions" ON transactions
  FOR INSERT WITH CHECK (TRUE); -- Will be restricted at application level

-- RLS Policies for credit_ledger table
CREATE POLICY "Users can read own ledger" ON credit_ledger
  FOR SELECT USING (auth.uid()::text = user_id::text);

-- Function to handle credit updates atomically
CREATE OR REPLACE FUNCTION process_referral_credit(
  p_referrer_id UUID,
  p_referred_id UUID,
  p_bonus_amount DECIMAL
)
RETURNS TABLE(
  success BOOLEAN,
  message TEXT,
  new_balance DECIMAL
) AS $$
DECLARE
  v_referral_id UUID;
  v_previous_balance DECIMAL;
  v_new_balance DECIMAL;
BEGIN
  -- Start transaction
  BEGIN
    -- Check if referral exists and is pending
    SELECT id INTO v_referral_id
    FROM referrals
    WHERE referrer_id = p_referrer_id 
      AND referred_id = p_referred_id 
      AND status = 'pending'
    FOR UPDATE;

    IF v_referral_id IS NULL THEN
      RETURN QUERY SELECT FALSE, 'Referral not found or already processed', 0::DECIMAL;
      RETURN;
    END IF;

    -- Get previous balance
    SELECT credits INTO v_previous_balance
    FROM users
    WHERE id = p_referrer_id
    FOR UPDATE;

    -- Update user credits
    UPDATE users
    SET credits = credits + p_bonus_amount,
        total_earned = total_earned + p_bonus_amount,
        updated_at = NOW()
    WHERE id = p_referrer_id
    RETURNING credits INTO v_new_balance;

    -- Mark referral as completed
    UPDATE referrals
    SET status = 'completed',
        bonus_credits = p_bonus_amount,
        completed_at = NOW()
    WHERE id = v_referral_id;

    -- Create transaction record
    INSERT INTO transactions (user_id, referral_id, type, amount, description, status)
    VALUES (p_referrer_id, v_referral_id, 'earn', p_bonus_amount, 'Referral bonus', 'completed');

    -- Create ledger entry
    INSERT INTO credit_ledger (user_id, transaction_id, previous_balance, new_balance)
    SELECT p_referrer_id, id, v_previous_balance, v_new_balance
    FROM transactions
    WHERE user_id = p_referrer_id AND referral_id = v_referral_id
    ORDER BY created_at DESC
    LIMIT 1;

    RETURN QUERY SELECT TRUE, 'Credit processed successfully', v_new_balance;

  EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error processing credit: ' || SQLERRM, 0::DECIMAL;
  END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION process_referral_credit(UUID, UUID, DECIMAL) TO authenticated;
