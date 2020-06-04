/**
 * Merge 3 country data into one genotype file to feed calc_grm.
 * A country index file was also written to indict ID and its country.
 */
#include <iostream>
#include <sstream>
#include <fstream>
#include <map>

using namespace std;
int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);

  map<string, int> dic;		// read dictionary from stdin
  for(string line; getline(cin, line); ){
    stringstream ss(line);
    int id, t;
    string name;
    ss>>id>>t>>t>>name;
    dic[name] = id;
  }
  
  ofstream foo(argv[argc-1]);	// the last argument for country.idx
  for(auto i{1}; i<argc-1; ++i){
    int ix[argc-2]{0};
    ix[i-1] = 1;
    
    ifstream fin(argv[i]);
    string line, id, dum;
    getline(fin, dum);		// skip the one-line header
    while(getline(fin, line)){
      stringstream ss(line);
      ss >> dum >> id >> dum >> dum >> dum >> dum;
      getline(ss, dum);
      cout << dic[id] << dum << '\n';
      foo << dic[id];
      for(auto&x:ix) foo << ' ' << x;
      foo << '\n';
    }
  }
    
  return 0;
}
