#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <vector>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  
  /** General description
   *
   * Read the physical map, which is super set of the current platform
   * Also output a SNP list
   */
  map<string, pair<string, int>> pmp;
  {
    // Read the 3-column map
    string snp, chr;		// chr can be a string, e.g., X, MT
    int bp;
    while(cin>>snp>>chr>>bp) pmp[snp] = {chr,bp};

    /** Abou the current map
     *
     * Using the first file in the directory to export a SNP map
     * This map [ chr snp linkage-distance bp ] x number of SNP
     * and in the order of the current final report file
     * I found that the order from German is different from others.
     */
    ifstream fin(argv[1]);
    ofstream foo("current.map");
    string line{"duummy"};
    while(line.substr(0, 6) != string("[Data]")) getline(fin, line);
    getline(fin, line);		// skip the data body header
    while(getline(fin, line)){
      stringstream ss(line);
      ss>>snp;
      foo<<pmp[snp].first<<' '<<snp<<" 0 "<<pmp[snp].second<<'\n';
    }
  }
  // Create a allele translation dictionary
  // Note all characters other than 'ACGT' are translated to missing, that is '0'
  map<char, char> tab;{
    string s{"-DIACGTacgt 000ACGTACGT"};
    for(auto i{0}; i<11; ++i) tab[s[i]] = s[i+12];
  }

  // Now deal one by on of the files in final report format
  for(auto i{1}; i<argc; ++i){
    ifstream fin(argv[i]);
    string line{"duummy"}, snp, id, gt;
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
