#include “myclass.h”

MyClass::MyClass(QObject *parent)
: QObject(parent)
{
}

QString MyClass::sayHello() const
{
return “Hello!”;
}
