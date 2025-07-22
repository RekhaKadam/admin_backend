
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { ShoppingCart, ArrowRight } from "lucide-react";

export const FloatingCart = () => {
  // TODO: Replace with actual cart state
  const itemCount = 3; // Made visible for demo purposes
  const totalAmount = 789;

  if (itemCount === 0) return null;

  return (
    <div className="floating-action animate-fade-in">
      <Button 
        className="w-full h-auto p-0 bg-gradient-to-r from-primary to-primary/90 hover:from-primary/90 hover:to-primary shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105"
        onClick={() => {
          // Navigate to cart - haptic feedback simulation
          console.log('Navigate to cart');
        }}
      >
        <div className="flex items-center justify-between w-full px-6 py-4">
          <div className="flex items-center gap-4">
            <div className="relative">
              <ShoppingCart className="w-6 h-6" />
              <Badge className="absolute -top-2 -right-2 w-6 h-6 text-xs bg-warning text-warning-foreground rounded-full p-0 flex items-center justify-center font-bold animate-pulse">
                {itemCount}
              </Badge>
            </div>
            <div className="text-left">
              <div className="text-heading font-semibold">{itemCount} items</div>
              <div className="text-caption opacity-90">₹{totalAmount}</div>
            </div>
          </div>
          <div className="flex items-center gap-3">
            <span className="text-subheading font-semibold">View Cart</span>
            <ArrowRight className="w-5 h-5" />
          </div>
        </div>
      </Button>
    </div>
  );
};
