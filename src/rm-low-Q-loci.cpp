#include <iostream>
#include <sstream>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  double threshold(stod(argv[1]));
  for(string line; getline(cin, line);)
    if(line[0] == '#') cout<<line<<'\n';
    else{
      double tt{0}, vld{0};
      stringstream ss(line);
      string dum;
      for(auto i{0}; i<9; ++i) ss>>dum;
      while(ss>>dum){
	++tt;
	if(dum[0] != '.') ++vld;
      }
      if(vld/tt >threshold) cout<<line<<'\n';
    }
  return 0;
}
