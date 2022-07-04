# LeetCode 169 : Majority Element

Link: https://leetcode.com/problems/majority-element/

## Problem

 Given an array of size `n`, return the `majority` element which frequency is more than `n/2 + 1`

## Solution Idea

  While traversing the array...

  - current = nums[i], if count == 0
  - count + 1, if the element matches with the current element
  - count - 1, if the element doesn't match

   Since there will always be a majority element, the last current element will be the answer.

**Time Complexity: O(n)**

**Space Complexity: O(1)**

## Follow Up

The current element doesn't always exist

 In that case, we will traverse the array again to check if the last current element is the majority element.
 If the checks fail, we will return none.
