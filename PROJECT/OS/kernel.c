 #include "kernel.h"
 #include "common.h"
 typedef unsigned char uint8_t;
 typedef unsigned int uint32_t;
 typedef uint32_t size_t;

 extern char __bss[], __bss_end[], __stack_top[];

struct sbiret sbi_call(long arg0, long arg1, long arg2, long arg3, long arg4, long arg5, long fid, long eid)
{
   register long a0 __asm__("a0") =arg0;
   register long a1 __asm__("a1") =arg0;
   register long a2 __asm__("a2") =arg0;
   register long a3 __asm__("a3") =arg0;
   register long a4 __asm__("a4") =arg0;
   register long a5 __asm__("a5") =arg0;
   register long a6 __asm__("a6") =fid;
   register long a7 __asm__("a7") =eid;

   __asm__ __volatile__(
      "ecall"
      : "=r"(a0), "=r"(a1)
      : "r"(a0), "r"(a1), "r"(a2), "r"(a3), "r"(a4), "r"(a5), "r"(a6), "r"(a7)
      : "memory"
   );
   return (struct sbiret){.error = a0, .value= a1}; 
};

void putchar(char ch){
   sbi_call(ch, 0, 0, 0, 0, 0, 0, 1);
}


 void kernel_main(void){
    memset(__bss, 0, (size_t) __bss_end - (size_t) __bss);   
    PANIC("booted!");
    printf("unreachable here!\n");
    /*  
    const char *s = "\n\nHello World!\n";
    for (int i = 0; s[i] != '\0'; i++)
    {
      putchar(s[i]);
    }
    */
   printf("\n\nHello %s\n", "World");
   printf("1 + 2 = %d, %x\n", 1+2, 0x1234abcd);

    for(;;){
      __asm__ __volatile__("wfi");
    }

 }

 __attribute((section(".text.boot")))
 __attribute((naked))
 void boot(void){
    __asm__ __volatile__(
        "mv sp, %[stack_top]\n"
        "j kernel_main\n"
        :
        : [stack_top] "r" (__stack_top)
    );
 }