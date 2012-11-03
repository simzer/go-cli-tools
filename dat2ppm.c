#include <stdlib.h> 
#include <stdio.h> 
#include <math.h> 

#define size 19

typedef signed char tTable[size*size];
typedef double tField[size*size];

void load(char* filename, tTable table)
{
  FILE *f;
  f = fopen(filename,"r");
  fread(table,1,size*size,f);
  fclose(f);  
}

void save(char* filename, tTable table)
{
  FILE *f;
  f = fopen(filename,"w");
  fwrite(table,1,size*size,f);
  fclose(f);  
}


void setTableXY(tTable table, int x, int y, int c) 
{
  table[x + y * size] = (c == 0) ? -127 : 127;
}

void initTable(tTable table)
{
  int i;
  for (i = 0; i < size*size; i++) table[i] = 0;
}

void clearField(tField field)
{
  int i;
  for (i = 0; i < size*size; i++) field[i] = 0;
}

double count(tField field) 
{
  double teritory_thold = 0.001;
  int i;
  double result = 0;
  for (i = 0; i < size*size; i++) {
    result += (fabs(field[i]) > teritory_thold) ? field[i] : 0;
    field[i] = (fabs(field[i]) < teritory_thold) ? 0 : field[i];
  }
  return result;
}

void savePPM(char* filename, tField field, int width)
{
  int cb[3] = { 0, 0, 0};
  int c0[3] = { 192, 192, 255};
  int c1[3] = { 255, 192, 0};
  int x, y, i, j, c[3];
  double max = 0;
  FILE *f;
  f = fopen(filename,"w");
  fprintf(f, "P3\n");
  fprintf(f, "%d %d\n", width, width);
  fprintf(f, "255\n");
  for (i = 0; i < size*size; i++) if (fabs(field[i]) > max) max = fabs(field[i]);
  for(y = 0; y < width; y++) {
    for(x = 0; x < width; x++) {
      double d = field[(size*x)/width + size*((size*y)/width)];
      double a0 = (d >= 0) ? (d/max) : 0;
      double a1 = (d <= 0) ? (-d/max) : 0;
      for(j = 0; j < 3; j++) c[j] = cb[j] * (1-(a0+a1)) + c0[j] * a0 + c1[j] * a1;
      fprintf(f, "%d %d %d ", c[0], c[1], c[2]);
    }
    fprintf(f, "\n");
  }
  fclose(f);  
}

int inrange(int x, int y)
{
  return ( x >= 0 && y >= 0 && x < size && y < size );
}

void process(tTable table, tField z, int iteration)
{
  double s = 10, c0 = 5, c1 = 50, g = 1, dt = 0.01, zmax=0.1;
  int i, x, y;
  tField dz;
  tField ddz;
  clearField(dz);  
  for(i = 0; i < iteration; i++) {
    for(y = 0; y < size; y++) {
      for(x = 0; x < size; x++) {
        ddz[y*size+x] = - c0 * z[y*size+x] 
                        + c1 * (inrange(x-1,y) ? z[y*size+(x-1)] - z[y*size+x] : 0 )
                        + c1 * (inrange(x+1,y) ? z[y*size+(x+1)] - z[y*size+x] : 0 )
                        + c1 * (inrange(x,y-1) ? z[(y-1)*size+x] - z[y*size+x] : 0 )
                        + c1 *(inrange(x,y+1) ? z[(y+1)*size+x] - z[y*size+x] : 0 )
                        - s * dz[y*size+x]
                        - g * table[y*size + x];
        dz[y*size+x] += ddz[y*size+x] * dt;
        z[y*size+x]  += dz[y*size+x] * dt;
        if (z[y*size+x] > zmax) { z[y*size+x] = zmax; }
        if (z[y*size+x] < -zmax) { z[y*size+x] = -zmax; }
      }
    }
  }
}

int main(int argc, char **argv)
{
  char *filename = argv[1];
  char *imgname = argv[2];
  tTable table;
  tField field;
  clearField(field);
  initTable(table);
  load(filename, table);
  process(table, field, 100);
  printf("%f\n", count(field));
  //save(filename, table);
  savePPM(imgname, field, size*1);
}