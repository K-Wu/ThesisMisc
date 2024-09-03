// Result: https://godbolt.org/z/WqKGfs9E4
// Based on https://www.geeksforgeeks.org/sorting-vector-tuple-c-ascending-order/
#include <bits/stdc++.h>
using namespace std;

int main()
{
    vector<tuple<string, string> > v{{"Alice","227 CSL"},{"Bob","1210 Siebel Center"},{"Charlie", "2120 ECE Building"}};

    sort(v.begin(), v.end(), [](const tuple<string, string>& a, const tuple<string, string>& b) { // a's type and b's type can be written as auto
        return get<1>(a) < get<1>(b);
    });

    // i's type can be written as auto
    for (int i = 0; i < v.size(); i++)
        cout << get<0>(v[i]) << " " << get<1>(v[i]) << " " << "\n";
        
    return 0;
}