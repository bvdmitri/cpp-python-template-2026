// TDD: this test is written BEFORE the implementation in src/sum.cpp.
//
// The library's "feature" (summing two numbers) is intentionally trivial — it
// exists only to exercise the full template infrastructure. These tests model
// the expected workflow: classic assertion-style cases plus a BDD-style
// SCENARIO. When extending the library, add a failing test here first.
#include <mylib/mylib.hpp>

#include <catch2/catch_test_macros.hpp>
#include <catch2/matchers/catch_matchers_floating_point.hpp>

#include <limits>

TEST_CASE("sum adds two integers", "[sum]")
{
    REQUIRE(mylib::sum(2, 3) == 5);
    REQUIRE(mylib::sum(-4, 4) == 0);
    REQUIRE(mylib::sum(-7, -8) == -15);
}

TEST_CASE("sum is constexpr-evaluable", "[sum][constexpr]")
{
    // If sum() were not usable in a constant expression this would fail to
    // compile, so this static_assert is itself part of the contract.
    static_assert(mylib::sum(20, 22) == 42);
    STATIC_REQUIRE(mylib::sum(1, 1) == 2);
}

TEST_CASE("sum adds floating-point values", "[sum][float]")
{
    using Catch::Matchers::WithinRel;
    REQUIRE_THAT(mylib::sum(0.1, 0.2), WithinRel(0.3, 1e-12));
    REQUIRE_THAT(mylib::sum(-1.5F, 2.5F), WithinRel(1.0F, 1e-6F));
}

TEST_CASE("sum has a runtime (non-template) overload", "[sum][runtime]")
{
    // Forces use of the symbol defined in src/sum.cpp, proving the compiled
    // translation unit links and installs/exports correctly.
    const long long a = 9'000'000'000LL;
    const long long b = 1'000'000'000LL;
    REQUIRE(mylib::sum(a, b) == 10'000'000'000LL);
}

SCENARIO("summing balances on an account", "[sum][bdd]")
{
    GIVEN("a starting balance")
    {
        const int balance = 100;

        WHEN("a deposit is added")
        {
            const int updated = mylib::sum(balance, 50);
            THEN("the balance increases by the deposit")
            {
                REQUIRE(updated == 150);
            }
        }

        WHEN("a withdrawal (negative) is applied")
        {
            const int updated = mylib::sum(balance, -30);
            THEN("the balance decreases accordingly")
            {
                REQUIRE(updated == 70);
            }
        }
    }
}
