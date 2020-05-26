/**
 * Merge 3 country data into one genotype file to feed calc_grm.
 * A country index file was also written to indict ID and its country.
 */
#include <iostream>
#include <sstream>
#include <fstream>

using namespace std;
int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  
  ofstream foo("country.idx");
  ofstream dic("ID.dic");
  int num{0};
  
  for(auto i{1}; i<argc; ++i){
    int ix[argc-1]{0};
    ix[i-1] = 1;
    
    ifstream fin(argv[i]);
    string line, id, dum;
    getline(fin, dum);		// skip the one-line header
    while(getline(fin, line)){
      ++num;
      stringstream ss(line);
      ss >> dum >> id >> dum >> dum >> dum >> dum;
      getline(ss, dum);
      cout << num << dum << '\n';
      foo << num;
      for(auto&x:ix) foo << ' ' << x;
      foo << '\n';
      dic << num << ' ' << id <<'\n';
    }
  }
    
  return 0;
}
