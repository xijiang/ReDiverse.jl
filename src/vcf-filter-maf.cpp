#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>
#include <map>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  
  double maf(stof(argv[1]));	// e.g., 0.01

  string line{"##"};
  while(line[1] == '#'){
    getline(cin, line);
    cout << line << '\n';
  }
  int nid{-9};
  {
    string f;
    stringstream ss(line);
    while(ss>>f) ++nid;
  }
  int nlc[nid]{0};
  while(getline(cin, line)){
    stringstream ss(line);
    string f;
    double frq{0.}, tt{0.};
    for(auto i{0}; i<9; ++i) ss>>f;
    for(auto i{0}; i<nid; ++i){
      ss>>f;
      if(f[0] != '.'){
	tt+=2;
	++nlc[i];
	if(f[0] == '1') ++frq;
	if(f[2] == '1') ++frq;
      }
    }
    frq /= tt;
    if(frq>.5) frq = 1-frq;
    if(frq>=maf) cout<<line<<'\n';
  }
  ofstream foo(argv[2]);
  for(auto&x:nlc) foo<<x<<'\n';
  
  return 0;
}
