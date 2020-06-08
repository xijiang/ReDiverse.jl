/**
 * convert plink.raw to calc_grm -> genotypes.txt.
 * also translate original ID names to recoded integer names.
 */
#include <iostream>
#include <sstream>
#include <algorithm>
#include <cctype>

using namespace std;

int main(int argc, char *argv[])
{
  string line;
  getline(cin, line);
  while(getline(cin, line)){
    stringstream ss(line);
    int id, t;
    ss>>t>>id>>t>>t>>t>>t;
    getline(ss, line);
    line.erase(remove_if(line.begin(), line.end(), ::isspace), line.end());
    cout<<id<<' '<<line<<'\n';
  }
  return 0;
}
