import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage() : super();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Client httpClient;
  Web3Client ethClient;
  bool data = false;
  TextEditingController Amt= TextEditingController();
  final myAddress = '0xD020EDf17Cec6ac28B54ff56e40D4a9aC71bD643';
  var myData;
  @override
  void initState(){
    super.initState();
    httpClient = Client();
    ethClient=Web3Client("https://rinkeby.infura.io/v3/bd12a7232a814ca58772359386f7a2de",
        httpClient);
    getBalance(myAddress);
  }
  Future<DeployedContract> loadContract()async{
    String abi =  await rootBundle.loadString("assets/abi_services.json");
    String contractAddress = "0x6097984C119De3ED77D502801c54E8b511F4BE60" ;

    final contract =DeployedContract(ContractAbi.fromJson(abi, "PKCoin"),EthereumAddress.fromHex(contractAddress) );
    return contract;
  }
  Future<List<dynamic>>query(String functionName,List<dynamic> args)async{
    final contract =await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(contract: contract, function: ethFunction, params: args);

    return result;
  }

  Future<void> getBalance(String targetAddress)async{
    EthereumAddress address =EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await query("getBalance",[]);
    myData =result[0];
    data=true;
    setState(() {

    });
  }
  
  Future<String> submit(String functionName, List<dynamic> args)async{
    EthPrivateKey credential =EthPrivateKey.fromHex("cdf57864ee106d6d4c21e2ac8b6315c32a35a96e98ce3635c8f4858e14931578");
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(credential, Transaction.callContract(contract: contract, function: ethFunction, parameters: args ),fetchChainIdFromNetworkId: true);
    return result;

  }
  
  Future<String> sendCoin()async{
    var bigAmouunt=BigInt.from(int.tryParse(Amt.text));
    var response = await submit("depositeBalance",[bigAmouunt]);
    print("deposited");
    return response;
  }
  Future<String> withdrawCoin()async{
    var bigAmouunt=BigInt.from(int.parse(Amt.text));
    var response = await submit("withdrawBalance",[bigAmouunt]);
    print("withdrawn");
    return response;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.gray300,
      body: ZStack([
        VxBox()
            .blue600
            .size(context.screenWidth, context.percentHeight * 30)
            .make(),
        VStack([
          (context.percentHeight * 10).heightBox,
          "\$PKCOIN".text.xl4.white.bold.center.makeCentered().py16(),
          (context.percentHeight * 5).heightBox,
          VxBox(
                  child: VStack([
            "Balance".text.gray700.xl2.semiBold.makeCentered(),
            10.heightBox,
            data
                ? "\$$myData".text.bold.xl6.makeCentered().shimmer()
                : CircularProgressIndicator().centered()
          ]))
              .p16
              .white
              .size(context.screenWidth, context.percentHeight * 18)
              .rounded
              .shadowXl
              .make()
              .p16(),
          30.heightBox,
          HStack([
            FlatButton.icon(
                onPressed: () {getBalance(myAddress);},
                color: Colors.blue,
                shape: Vx.roundedSm,
                icon: Icon(Icons.refresh, color: Colors.white,),
                label: "Refresh".text.white.make()),
            FlatButton.icon(
                onPressed: () {sendCoin();},
                color: Colors.green,
                shape: Vx.roundedSm,
                icon: Icon(Icons.call_made_outlined, color: Colors.white,),
                label: "Deposit".text.white.make()),
            FlatButton.icon(
                onPressed: () {withdrawCoin();},
                color: Colors.red,
                shape: Vx.roundedSm,
                icon: Icon(Icons.call_received_outlined, color: Colors.white,),
                label: "Withdraw".text.white.make())
          ],
          alignment:MainAxisAlignment.spaceAround,
          axisSize: MainAxisSize.max,),
          20.heightBox,

          Center(
            child:        Container(
              child: TextField(
                controller: Amt,
                decoration: InputDecoration(
                  hintText: " Username ",
                  prefixIcon: Icon(Icons.attach_money ),
                  border: InputBorder.none,
                ),
              ),
              padding: EdgeInsets.fromLTRB(16, 0, 24, 0),
              width: context.screenWidth * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ]),

      ]),
    );
  }
}
