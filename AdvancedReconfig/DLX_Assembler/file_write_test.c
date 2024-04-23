#include <stdio.h>
#include <string.h>

int main () {
   char src[40];
   char* dest = NULL;
  
   memset(dest, '\0', sizeof(dest));
   strcpy(src, "This is tutorialspoint.com");
   strncpy(dest, src+2, 10);

   printf("Final copied string : %s\n", dest);
   
   return(0);
}