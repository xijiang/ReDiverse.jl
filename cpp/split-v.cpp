/**
 * This is to split a final report with many ID stacked side by side
 * and sharing one header. Each splitted file will have the `ID name`.txt 
 * as the file name.
 * Usage:
 *     cat the-final-report | this-program inc shortlist-dict
 */

#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>
#include <map>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  map<string, string> sdc;	// shortlist dictionary GenofileId -> GenoId
  {
    ifstream fin(argv[1]);
    for(string a, b; fin>>a>>b; sdc[a] = b);
  }

  vector<string> ID, SNP, header;
  map<string, vector<string>> GT;
  string line;
  while(getline(cin, line)){
    header.push_back(line);
    if(line.substr(0, 6) == "[Data]") break;
  }
  header.push_back("SNP Name\tSample ID\tAllele1 - Top\tAllele2 - Top\tGC Score");
  getline(cin, line);
  {
    stringstream ss(line);
    for(string id; ss>>id; ID.push_back(id));
  }
  while(getline(cin, line)){
    stringstream ss(line);
    string snp, gt;
    ss>>snp;
    SNP.push_back(snp);
    for(auto&id:ID)
      if(ss>>gt) GT[id].push_back(gt);
      else cerr<<"Not enough fields at SNP: "<<snp<<endl;
  }
  for(auto&id:ID){
    clog <<"\rID "<<id;
    if(sdc.find(id) == sdc.end()){
      clog<<" is ignored.    "<<flush;
      continue;
    }

    clog<<" -> "<<sdc[id]<<"                    "<<flush;
    ofstream foo(sdc[id]+".txt");
    for(auto&t:header) foo<<t<<'\n';
    auto&dat = GT[id];
    for(size_t i=0; i<SNP.size(); ++i){
      string&snp=SNP[i];
      string&gt =dat[i];
      foo<<snp<<'\t'<<sdc[id]<<'\t'<<gt[0]<<'\t'<<gt[1]<<'\t'<<gt.substr(3)<<'\n';
    }
  }
  clog<<endl;
  return 0;
}
