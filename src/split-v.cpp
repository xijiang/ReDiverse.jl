/**
 * This is to split a final report with many ID stacked side by side
 * and sharing one header. Each splitted file will have the `ID name`.txt 
 * as the file name.
 * Usage:
 *     cat the-final-report | this-program
 */

#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>

using namespace std;

int main(int argc, char *argv[])
{
  vector<string> ID, SNP, header, GT;
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
    while(ss>>gt) GT.push_back(gt);
  }
  int nid(ID.size());
  for(auto iid{0}; iid<nid; ++iid){
    auto&id = ID[iid];
    int ilc = iid;
    ofstream foo(id + ".txt");
    for(auto&l:header) foo<<l<<'\n';
    for(auto&snp:SNP){
      auto&gt = GT[ilc];
      ilc += nid;
      foo<<snp<<'\t'<<id<<'\t'<<gt[0]<<'\t'<<gt[1]<<'\t'<<gt.substr(3)<<'\n';
    }
  }
  return 0;
}
