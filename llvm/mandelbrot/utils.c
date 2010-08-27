#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include "bmpfile.h"

void write_image(int **img, int width, int height) {
  
  int left = sizeof(**img)*width*height;
  char *buf = (char*) img;
  int fd = open("image.rgb", O_CREAT| O_WRONLY);

  do {
    
    int w = write(fd, buf, left);
    
    if (w == -1) {
      printf("Could not write file");
      exit(-1);
    }
    left -= w;
    buf += w;
  } while (left > 0);

  close(fd);
}

void write_bmp(int *img, int width, int height) {
  bmpfile_t *bmp;
  int i, j;

  if ((bmp = bmp_create(width, height, 32)) == NULL) {
    printf("Could not create bitmap");
    exit(-1);
  }

  for (j = 0; j < height; ++j) {
    for (i = 0; i < width; ++i) {
      int index = j*width+i;
      int c = img[index];
      rgb_pixel_t p = {0, 0, 0, 0};
  
      p.red = (c+64) % 256;
      p.green = (c-47) % 200;
      p.blue = (c-73) % 180;
      	
      bmp_set_pixel(bmp, i, j, p);
    }
  }
  bmp_save(bmp, "image.bmp");
  bmp_destroy(bmp);
}

