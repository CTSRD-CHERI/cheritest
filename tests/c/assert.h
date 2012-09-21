
__attribute__((noreturn)) int __assert_fail(int);
void  __assert(int cond, int line)
{
	if (!cond)
	{
		__assert_fail(line);
	}
}
#define assert(cond) __assert(cond, __LINE__)
