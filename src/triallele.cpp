#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <map>

using namespace std;

int main(int argc, char *argv[])
{
  ifstream fin[argc-1];
  string line, snp, id;
  char a, b;

  for(auto i{1}; i<argc; ++i){
    fin[i-1].open(argv[i]);
    for(auto k{0}; k<11; ++k) getline(fin[i-1], line);
  }
  while(getline(fin[0], line)){
    map<char, int> count;
    stringstream ss(line);
    ss>>snp>>id>>a>>b;
    ++count[a];
    ++count[b];
    for(auto i{1}; i<argc-1; ++i){
      getline(fin[1], line);
      stringstream ss(line);
      ss>>snp>>id>>a>>b;
      ++count[a];
      ++count[b];
    }
    cout <<setw(40) << snp;
    for(const auto&[m,c]:count) cout<<setw(6)<<m<<setw(5)<<c;
    cout<<'\n';
  }
  return 0;
}
