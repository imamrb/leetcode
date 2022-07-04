class Solution {
public:
    int majorityElement(vector<int>& nums) {
        int len = nums.size();

        int current = 0, cnt = 0;

        for(int i = 0; i<len; i++) {
            if(cnt==0) current = nums[i];

            nums[i] == current ? cnt++ : cnt--;
        }

        return current;
    }
};
