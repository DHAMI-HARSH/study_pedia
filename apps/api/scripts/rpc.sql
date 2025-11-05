-- Idempotent purchase processing RPC
CREATE OR REPLACE FUNCTION public.process_purchase(
  user_id UUID,
  amount DECIMAL,
  idempotency_key TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_purchase_id UUID;
  v_purchase_status TEXT;
  v_referrer_id UUID;
  v_referral_reward DECIMAL := amount * 0.1; -- 10% referral bonus
  v_new_credits DECIMAL;
BEGIN
  -- Step 1: Check if purchase already exists (idempotency)
  SELECT id, status INTO v_purchase_id, v_purchase_status
  FROM public.purchases
  WHERE idempotency_key = idempotency_key
  LIMIT 1;

  IF v_purchase_id IS NOT NULL THEN
    -- Return existing purchase result
    RETURN json_build_object(
      'purchase_id', v_purchase_id,
      'status', v_purchase_status,
      'amount', amount,
      'is_duplicate', true
    );
  END IF;

  -- Step 2: Create purchase record
  INSERT INTO public.purchases (user_id, amount, idempotency_key, status)
  VALUES (user_id, amount, idempotency_key, 'completed')
  RETURNING id INTO v_purchase_id;

  -- Step 3: Add credits to user
  UPDATE public.users
  SET credits = credits + amount,
      updated_at = NOW()
  WHERE id = user_id
  RETURNING credits INTO v_new_credits;

  -- Step 4: Check if user was referred and create reward
  SELECT referred_by INTO v_referrer_id
  FROM public.users
  WHERE id = user_id;

  IF v_referrer_id IS NOT NULL THEN
    INSERT INTO public.referral_rewards (referrer_id, referred_user_id, reward_amount)
    VALUES (v_referrer_id, user_id, v_referral_reward)
    ON CONFLICT (referrer_id, referred_user_id) DO UPDATE
    SET reward_amount = referral_rewards.reward_amount + v_referral_reward;
  END IF;

  -- Step 5: Return success response
  RETURN json_build_object(
    'purchase_id', v_purchase_id,
    'status', 'completed',
    'amount', amount,
    'user_credits', v_new_credits,
    'referral_reward_issued', v_referrer_id IS NOT NULL,
    'referral_amount', CASE WHEN v_referrer_id IS NOT NULL THEN v_referral_reward ELSE 0 END
  );
EXCEPTION
  WHEN OTHERS THEN
    -- Update purchase status to failed
    UPDATE public.purchases
    SET status = 'failed', updated_at = NOW()
    WHERE id = v_purchase_id;

    RETURN json_build_object(
      'status', 'failed',
      'error', SQLERRM
    );
END;
$$;

-- Function to generate unique referral codes
CREATE OR REPLACE FUNCTION public.generate_referral_code()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  v_code TEXT;
  v_exists BOOLEAN;
BEGIN
  LOOP
    -- Generate random 8-character alphanumeric code
    v_code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT || CLOCK_TIMESTAMP()::TEXT), 1, 8));
    
    -- Check if code already exists
    SELECT EXISTS(SELECT 1 FROM public.users WHERE referral_code = v_code) INTO v_exists;
    
    EXIT WHEN NOT v_exists;
  END LOOP;

  RETURN v_code;
END;
$$;

-- Trigger to auto-generate referral code
CREATE OR REPLACE FUNCTION public.set_referral_code()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.referral_code IS NULL THEN
    NEW.referral_code := generate_referral_code();
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_set_referral_code ON public.users;
CREATE TRIGGER trigger_set_referral_code
BEFORE INSERT ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.set_referral_code();
