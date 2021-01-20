#include "../uuidxx.h"
#include <cassert>
#include <string>
#include <iostream>
#include <set>
#include <array>
#include <string.h>

#ifdef _WIN32
#define strcasecmp _stricmp
#endif

using namespace uuidxx;
using namespace std;

bool TestEquality()
{
	bool result = true;

	uuid test1, test2;

	auto passTest = [&](bool reverse = false) {
		if ((test1 != test2) ^ reverse)
		{
			cout << "FAIL!" << endl;
			cout << "\tFailed on: " << test1.ToString() << " vs " << test2.ToString() << endl;
			result = false;
		}
		else
		{
			cout << "pass" << endl;
		}
	};

	cout << "Testing assignment... ";
	test1 = uuid::Generate();
	test2 = test1;
	passTest();

	cout << "Testing move operator... ";
	test1 = uuid::Generate();
	test2 = std::move(test1);
	passTest(false);

	cout << "Testing equality of normal GUIDs... ";
	test1 = uuid("2C121B80-14B1-4B5A-AD48-9043DC251FDF");
	test2 = uuid("2C121B80-14B1-4B5A-AD48-9043DC251FDF");
	passTest();


	cout << "Testing equality of lower- vs upper-cased GUIDs... ";
	test1 = uuid("2C121B80-14B1-4B5A-AD48-9043DC251FDF");
	test2 = uuid("2c121b80-14b1-4b5a-ad48-9043dc251fdf");
	passTest();

	cout << "Testing equality of braced vs non-braced GUIDs... ";
	test1 = uuid("2C121B80-14B1-4B5A-AD48-9043DC251FDF");
	test2 = uuid("{2C121B80-14B1-4B5A-AD48-9043DC251FDF}");
	passTest();

	cout << "Testing inequality of random GUIDs... ";
	test1 = uuid::Generate();
	test2 = uuid::Generate();
	passTest(true);

	return result;
}

bool InnerTestParsing(string test, string testCase, bool &result)
{
	cout << "Testing " << test << " parsing: " << testCase << "... ";
	uuid test1(testCase);
	string strValue = test1.ToString();
	if (strcasecmp(strValue.c_str(), "{A04CB1DE-25F7-4BC0-A1CE-1D0246FF362B}") != 0)
	{
		cout << "FAIL!" << endl;
		cout << "\tFailed on: " << strValue.c_str() << " vs " << "A04CB1DE-25F7-4BC0-A1CE-1D0246FF362B" << endl;
		result = false;
		return false;
	}

	cout << "pass" << endl;
	return true;
}

bool TestParsing()
{
	bool result = true;

	InnerTestParsing("basic", "A04CB1DE-25F7-4BC0-A1CE-1D0246FF362B", result);
	InnerTestParsing("braces", "{A04CB1DE-25F7-4BC0-A1CE-1D0246FF362B}", result);
	InnerTestParsing("lower-case", "a04cb1de-25f7-4bc0-a1ce-1d0246ff362b", result);
	InnerTestParsing("mixed-case", "A04cb1de-25f7-4bc0-a1ce-1d0246ff362b", result);
	InnerTestParsing("left-brace", "{A04CB1DE-25F7-4BC0-A1CE-1D0246FF362B", result);
	InnerTestParsing("right-brace", "A04CB1DE-25F7-4BC0-A1CE-1D0246FF362B}", result);

	return result;
}

bool TestStringGeneration()
{
	bool result = true;

	uuid test("BAA55AAB-F3FC-461C-9789-8CC6E2E2CE8C");

	cout << "Testing generation of string without braces... ";
	//don't use
	//if (test.ToString(false) == "....")
	//because the temporary result may be optimized away
	if (strcmp(test.ToString(false).c_str(), "BAA55AAB-F3FC-461C-9789-8CC6E2E2CE8C") == 0)
	{
		cout << "pass" << endl;
	}
	else
	{
		cout << "FAIL!" << endl;
		result = false;
	}

	cout << "Testing generation of string without braces... ";
	if (strcmp(test.ToString(true).c_str(), "{BAA55AAB-F3FC-461C-9789-8CC6E2E2CE8C}") == 0)
	{
		cout << "pass" << endl;
	}
	else
	{
		cout << "FAIL!" << endl;
		result = false;
	}

	return result;
}

bool TestUniqueness()
{
	int rounds = 4096;
	cout << "Generating and testing uniqueness of " << rounds << " uuids... ";

	int collisions = 0;
	std::set<uuid> uuidMap;
	for (int i = 0; i < rounds; ++i)
	{
		auto test = uuid::Generate();
		if (uuidMap.insert(test).second == false)
		{
			++collisions;
		}
	}

	if (collisions == 0)
	{
		cout << "pass" << endl;
		return true;
	}
	else
	{
		cout << collisions << " collisions. FAIL!" << endl;
		return false;
	}
}

int main (int argc, char *argv[])
{
	auto tests = { TestStringGeneration, TestEquality, TestParsing, TestUniqueness };

	int fails = 0;
	for (auto test : tests)
	{
		if (!test())
		{
			++fails;
		}
	}

	assert(fails == 0);
	return fails;
}
