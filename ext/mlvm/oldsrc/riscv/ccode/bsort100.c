/* MDH WCET BENCHMARK SUITE. File version $Id: bsort100.c,v 1.5 2006/01/31 12:16:57 jgn Exp $ */

/* BUBBLESORT BENCHMARK PROGRAM:
 * This program tests the basic loop constructs, integer comparisons,
 * and simple array handling of compilers by sorting an array of 10 randomly
 * generated integers.
 */

/* Changes:
 * JG 2005/12/06: All timing code excluded (made to comments)
 * JG 2005/12/13: The use of memory based I/O (KNOWN_VALUE etc.) is removed
 *                Instead unknown values should be set using annotations
 * JG 2005/12/20: LastIndex removed from function BubbleSort
 *                Indented program.
 */

/* All output disabled for wcsim */
#define WCSIM 1

/* A read from this address will result in an known value of 1
#define KNOWN_VALUE (int)(*((char *)0x80200001))
*/

/* A read from this address will result in an unknown value
#define UNKNOWN_VALUE (int)(*((char *)0x80200003))
*/

/*
#include <sys/types.h>
#include <sys/times.h>
#include <stdio.h>
*/
#define WORSTCASE 1
#define FALSE 0
#define TRUE 1
#define NUMELEMS 20
#define MAXDIM   (NUMELEMS+1)

int             Array[MAXDIM], Seed;
int             factor;
void            BubbleSort(int Array[]);
void            Initialize(int Array[]);

int
main(void)
{
	Initialize(Array);
	BubbleSort(Array);
	return 0;
}


void Initialize(int Array[])
/*
 * Initializes given array with randomly generated integers.
 */
{
   int  Index, fact;

#ifdef WORSTCASE
   factor = -1;
#else
   factor = 1;
#endif

fact = factor;
for (Index = 1; Index <= NUMELEMS; Index ++) {
    Array[Index] = Index * fact/* * KNOWN_VALUE*/;
  }
}

void
BubbleSort(int Array[])
/*
 * Sorts an array of integers of size NUMELEMS in ascending order.
 */
{
	int             Sorted = FALSE;
	int             Temp, Index, i;

	for (i = 1;
	     i <= NUMELEMS - 1;	/* apsim_loop 1 0 */
	     i++) {
		Sorted = TRUE;
		for (Index = 1;
		     Index <= NUMELEMS - 1;	/* apsim_loop 10 1 */
		     Index++) {
			if (Index > NUMELEMS - i)
				break;
			if (Array[Index] > Array[Index + 1]) {
				Temp = Array[Index];
				Array[Index] = Array[Index + 1];
				Array[Index + 1] = Temp;
				Sorted = FALSE;
			}
		}

		if (Sorted)
			break;
	}

}
