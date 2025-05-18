#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{
    uid_t uid , euid ;
    uid = getuid();
    euid= geteuid();
  
    if(setreuid(euid,uid))  
    perror("setreuid");  
   
    printf("VOS3000 Firewall System By.CZMF\n",geteuid());  
    system("./ip");
    return 0;

}

