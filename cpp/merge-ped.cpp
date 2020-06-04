#include <iostream>
#include <fstream>
#include <sstream>

using namespace std;

int main(int argc, char *argv[])
{
  int tid{0};
  for(auto ped{1}; ped < argc; ++ped){
    clog << argv[ped] << endl;
    ifstream fin(argv[ped]);
    int nid{0}, id, pa, ma;
    string info;
    for(string line; getline(fin, line); ++nid){
      stringstream ss(line);
      ss>>id>>pa>>ma;
      getline(ss, info);
      cout << id+tid << ' '<< pa+tid <<' '<< ma+tid << info << '\n';
    }
    tid += nid;
  }
  return 0;
}
