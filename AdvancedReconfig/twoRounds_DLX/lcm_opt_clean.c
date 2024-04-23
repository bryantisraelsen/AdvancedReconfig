#include <stdio.h>
#include <stdlib.h>
#define N 2

unsigned long int lcm(unsigned long int a, unsigned long int b);

int main()
{
	unsigned long int nums[N];
	int i;
	unsigned long int prev_answer, curr_answer;
	
	printf("Enter %d numbers: ", N);
	for (i=0; i<N; i++)
	{
		scanf("%lu", &nums[i]);
	}
	printf("Made it out of initial loop\n");
		
	prev_answer = nums[0];
	for (i=1; i<N; i++)
	{
		curr_answer = lcm(prev_answer, nums[i]);
		prev_answer = curr_answer;
		printf("Finished iteration %d\n", i);
	}
	
	printf("LCM = %lu\n", nums[N-1]);
	
	return 0;
}

unsigned long int lcm(unsigned long int a, unsigned long int b)
{
	unsigned long int x, y;
	
	x = a;
	y = b;
	while (x != y)
	{
		if (x < y)
		{
			x = x + a;
		}
		else
		{
			y = y + b;
		}
	}
	return x;
}
