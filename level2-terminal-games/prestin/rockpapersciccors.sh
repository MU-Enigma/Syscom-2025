C=(Rock Paper Scissors); 
I=$((RANDOM%3)); 
read -r -p R/P/S:\  U;
 case ${U,,} in 
 r) R=0 ;; 
 p) R=1 ;; 
 s) R=2 ;; 
 *) exit 1 ;;
esac;
 L=$(((R-I+3)%3)); 
 E=(DRAW WIN LOSE); 
 echo "Comp: ${C[I]}, You: ${C[R]}";
  echo "You ${E[L]}!"
