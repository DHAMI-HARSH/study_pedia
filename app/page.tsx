import Image from "next/image";
import Navigation from "../components/Navigation";
import HeroSection from "../components/HeroSection"
import DynamicImageCarousel from "../components/dynamic-image-carousel"

export default function Home() {
  return (
    <main className="bg-background text-foreground">
      <Navigation />
      <HeroSection />
      <DynamicImageCarousel />

    </main>
    
  );
}
