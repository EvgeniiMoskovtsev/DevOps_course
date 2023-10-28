#include <iostream>
#include "lib.h"
int main() {
	std::cout << "Hello from main" << std::endl;
	MyClass myClass(1);
	std::cout << "My class variable " << myClass.mNumber << std::endl;
}