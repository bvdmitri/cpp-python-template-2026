/// @file sum.cpp
/// @brief Out-of-line definition of the non-template mylib::sum overload.
#include <mylib/sum.hpp>

namespace mylib {

long long sum(long long a, long long b) noexcept
{
    return a + b;
}

} // namespace mylib
