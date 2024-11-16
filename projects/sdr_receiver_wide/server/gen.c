#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <math.h>
#include <sys/mman.h>

int main(int argc, char *argv[])
{
  int fd, i;
  char *end;
  volatile void *cfg;
  long number[2];

  for(i = 0; i < 2; ++i)
  {
    errno = 0;
    number[i] = (argc == 4) ? strtol(argv[i + 1], &end, 10) : -1;
    if(errno != 0 || end == argv[i + 1])
    {
      fprintf(stderr, "Usage: gen [0-32766] [0-61440000]\n");
      return EXIT_FAILURE;
    }
  }

  if(number[0] < 0 || number[0] > 32766 || number[1] < 0 || number[1] > 61440000)
  {
    fprintf(stderr, "Usage: gen [0-32766] [0-61440000]\n");
    return EXIT_FAILURE;
  }

  if((fd = open("/dev/mem", O_RDWR)) < 0)
  {
    fprintf(stderr, "Cannot open /dev/mem.\n");
    return EXIT_FAILURE;
  }

  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);

    *(uint32_t *)(cfg + 16) = (uint32_t)floor(number[1] / 122.88e6 * (1<<30) + 0.5);
    *(uint16_t *)(cfg + 24) = (uint16_t)number[0];

  return EXIT_SUCCESS;
}
