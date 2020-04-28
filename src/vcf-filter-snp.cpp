#include <iostream>
#include <sstream>
#include <fstream>
#include <set>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);

  set<string> SNP;{
    ifstream fin(argv[1]);
    for(string snp; fin>>snp; SNP.insert(snp));
  }
  for(string line; getline(cin, line);)
    if(line[0] == '#') cout<<line<<'\n';
    else{
      stringstream ss(line);
      string snp;
      ss>>snp>>snp>>snp;
      if(SNP.find(snp) != SNP.end()) cout<<line<<'\n';
    }
  return 0;
}
