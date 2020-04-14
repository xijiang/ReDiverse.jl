#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <vector>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  map<string, pair<string, int>> pmp;
  {
    string snp, chr;		// chr can be a string, e.g., X, MT
    int bp;
    while(cin>>snp>>chr>>bp) pmp[snp] = {chr,bp};
    ifstream fin(argv[1]);
    ofstream foo("current.map");
    string line{"123456"};
    while(line.substr(0, 6) != string("[Data]")) getline(fin, line);
    getline(fin, line);
    while(getline(fin, line)){
      stringstream ss(line);
      ss>>snp;
      foo<<pmp[snp].first<<' '<<snp<<" 0 "<<pmp[snp].second<<'\n';
    }
  }
  string s{"-ACDGIT -AC-G-T"};
  map<char, char> tab;
  for(auto i{0}; i<7; ++i) tab[s[i]] = s[i+8];

  for(auto i{1}; i<argc; ++i){
    ifstream fin(argv[i]);
    string line{"123456"}, snp, id, gt;
    while(line.substr(0, 6) != string("[Data]")) getline(fin, line);
    getline(fin, line);
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
  for(auto&[a,b]:tab) clog<<a<<' '<<b<<'\n';

  return 0;
}
