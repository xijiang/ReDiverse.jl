#include <iostream>
#include <fstream>
#include <sstream>
#include <map>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  string s{"-ACDGIT -AC-G-T"};
  map<char, char> tab;
  for(auto i{0}; i<7; ++i) tab[s[i]] = s[i+8];
  
  for(auto i{1}; i<argc; ++i){
      ifstream fin(argv[i]);
    string line, snp, id, gt;
    for(auto k{0}; k<11; ++k) getline(fin, line);
    while(getline(fin, line)){
      stringstream ss(line);
      char a, b;
      ss>>snp>>id>>a>>b;
      gt += tab[a];
      gt += tab[b];
    }
    cout<<"dummy "<<id<<" 0 0 0 -9";
    for(auto&c:gt) cout<<' '<<c;
    cout<<'\n';
  }
  return 0;
}
