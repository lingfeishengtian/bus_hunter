import 'dart:convert';
import 'package:http/http.dart';
import 'bus_obj.dart';

const LINK = "https://aggiespirit.ts.tamu.edu/RouteMap/GetBaseData/";

/*
final httpsUri = Uri(
    scheme: 'https',
    host: 'dart.dev',
    path: 'guides/libraries/library-tour',
    fragment: 'numbers');
print(httpsUri); // 
*/

const HOST = "aggiespirit.ts.tamu.edu";

Future<List<BusRoute>> getRoutes() async {
  return await post(Uri(
    scheme: 'https',
    host: HOST,
    path: 'RouteMap/GetBaseData',
  )).then((value) {
    return (jsonDecode(value.body)['routes'] as List<dynamic>)
        .map((e) => BusRoute.fromJson(e))
        .toList();
  });
}

/*
{
  "routeKey": "50e00988-df23-4563-8f81-9382a7afc573",
  "patternPaths": [
    {
      "patternKey": "490083c9-e739-455f-a72b-38a03facf357",
      "directionKey": "5856d6e9-5da2-4378-9c55-c46838a2a279",
      "patternPoints": [
        {
          "key": "7c867d37-d5b3-44c7-b852-3e17f80cd1d7",
          "latitude": 30.6056067816196,
          "longitude": -96.3474036244909,
          "stop": {
            "name": "Reed Arena",
            "stopCode": "0050",
            "stopType": 0
          }
        },
        {
          "key": "8e2ba2ec-ac88-40a6-bf94-c259439b1439",
          "latitude": 30.6059794489133,
          "longitude": -96.3474024145247,
          "stop": null
        },
        {
          "key": "b6791ef0-25ff-4008-ad99-e725103a8eec",
          "latitude": 30.6061229471042,
          "longitude": -96.3472897617394,
          "stop": null
        },
        {
          "key": "266c6f24-1d61-4caa-93b0-844adb895a47",
          "latitude": 30.6064702931923,
          "longitude": -96.3467868475191,
          "stop": null
        },
        {
          "key": "5aa169df-646e-47c4-91c1-5a1ca7047dd3",
          "latitude": 30.6072400872254,
          "longitude": -96.3475365249834,
          "stop": null
        },
        {
          "key": "e0e73de1-bab7-4b8a-9b7e-2342d9fc2717",
          "latitude": 30.608330405255,
          "longitude": -96.3459218350602,
          "stop": null
        },
        {
          "key": "7eecf41e-4e5e-437f-80bf-28e19b73836f",
          "latitude": 30.6095937257763,
          "longitude": -96.3470389751815,
          "stop": null
        },
        {
          "key": "db0cc089-0804-41ed-974a-54c5ed8159bd",
          "latitude": 30.6097780832728,
          "longitude": -96.3466485915317,
          "stop": {
            "name": "Kleberg - Inbound",
            "stopCode": "0028",
            "stopType": 0
          }
        },
        {
          "key": "07e93dff-1350-43ee-8678-0a244662fd00",
          "latitude": 30.6102602547562,
          "longitude": -96.3461055663887,
          "stop": null
        },
        {
          "key": "6eb913da-dbea-4ee2-bdcd-2d783d0f9d5f",
          "latitude": 30.6113961703418,
          "longitude": -96.3471181003522,
          "stop": null
        },
        {
          "key": "efe81ca8-3130-44e5-9f11-bb06112b33fe",
          "latitude": 30.6115776243538,
          "longitude": -96.3467271130829,
          "stop": null
        },
        {
          "key": "35371520-95a9-4e14-adfe-7cb87566f7a0",
          "latitude": 30.6117569274757,
          "longitude": -96.3463912216658,
          "stop": null
        },
        {
          "key": "468a0871-de0e-4f4d-90c8-1d271c61d676",
          "latitude": 30.6125414736594,
          "longitude": -96.3451962974784,
          "stop": null
        },
        {
          "key": "d90e9de7-a23c-48cf-a3cf-a8f22425870a",
          "latitude": 30.6126125522025,
          "longitude": -96.3447322752912,
          "stop": null
        },
        {
          "key": "8ec6af7e-5733-4560-8ccb-551fff5f2cf2",
          "latitude": 30.6126912907402,
          "longitude": -96.3444936221348,
          "stop": null
        },
        {
          "key": "7c6ae626-12ce-4174-833d-561c7f0829f8",
          "latitude": 30.6128244467273,
          "longitude": -96.3442749586269,
          "stop": null
        },
        {
          "key": "60ac546d-7076-40a8-9eab-2b331773212d",
          "latitude": 30.6126912907402,
          "longitude": -96.3440445604626,
          "stop": null
        },
        {
          "key": "85d69ffa-c3da-45a0-8ae8-ef08c5dbf6cb",
          "latitude": 30.6124970479597,
          "longitude": -96.3435001452742,
          "stop": {
            "name": "MSC - ILCB",
            "stopCode": "0026",
            "stopType": 0
          }
        },
        {
          "key": "ff553168-b134-4f85-98ee-ab577984e7b0",
          "latitude": 30.6125441558685,
          "longitude": -96.3429915215368,
          "stop": null
        },
        {
          "key": "4a30a338-cf13-4181-b121-09b553046e6b",
          "latitude": 30.6127904521948,
          "longitude": -96.3425348860252,
          "stop": null
        },
        {
          "key": "fa966968-9007-4191-b242-efcaef8d0bf8",
          "latitude": 30.6130645044484,
          "longitude": -96.3421439434376,
          "stop": null
        },
        {
          "key": "bf3d5603-564e-44fc-9ced-3e14e231b6ba",
          "latitude": 30.6133777910357,
          "longitude": -96.3416751692713,
          "stop": null
        },
        {
          "key": "1462ff3f-11a3-42e6-a50e-9719154890ee",
          "latitude": 30.6135379737376,
          "longitude": -96.3414417753759,
          "stop": null
        },
        {
          "key": "7e90b0f6-64a5-45f1-a9c7-582b7d9c12c2",
          "latitude": 30.6136447620584,
          "longitude": -96.3414299579634,
          "stop": null
        },
        {
          "key": "642d3e21-3aa3-41c4-b89f-d76c22a09536",
          "latitude": 30.6137184967825,
          "longitude": -96.3414654102006,
          "stop": null
        },
        {
          "key": "5656653a-6cfb-43a6-8647-188b536cb74e",
          "latitude": 30.6157949933884,
          "longitude": -96.343263765768,
          "stop": null
        },
        {
          "key": "c8ed6d47-f8ab-4120-91af-6a8121a90cce",
          "latitude": 30.6159854302398,
          "longitude": -96.3433509375662,
          "stop": null
        },
        {
          "key": "16efd061-33b6-4f06-8c73-3b75b2f0d599",
          "latitude": 30.6163609395242,
          "longitude": -96.3433925118084,
          "stop": null
        },
        {
          "key": "08d7cff5-ff06-4614-8b45-7b2f4d45b5a8",
          "latitude": 30.616367432214,
          "longitude": -96.3431388164034,
          "stop": {
            "name": "Fish Pond",
            "stopCode": "0022",
            "stopType": 0
          }
        },
        {
          "key": "269af514-c89c-47b8-af8a-a9506e934a22",
          "latitude": 30.6165044377151,
          "longitude": -96.3429593350267,
          "stop": null
        },
        {
          "key": "0319a4f2-c28e-460c-aad4-d5f044af53b7",
          "latitude": 30.6168423960711,
          "longitude": -96.3424658085386,
          "stop": null
        },
        {
          "key": "92e6e010-f80f-4805-893a-c862805e38f6",
          "latitude": 30.617707482567,
          "longitude": -96.3411949838244,
          "stop": {
            "name": "Ross and Ireland - South",
            "stopCode": "0018",
            "stopType": 0
          }
        },
        {
          "key": "e22b2266-fa0a-47b1-b415-bd3a1f8e16e1",
          "latitude": 30.6189789430571,
          "longitude": -96.3394121347908,
          "stop": null
        },
        {
          "key": "6aef5289-6c95-4973-b60e-ecd8c8cc73f4",
          "latitude": 30.6196704836104,
          "longitude": -96.3383928829692,
          "stop": null
        },
        {
          "key": "db103efc-d7d8-4649-9304-6316c53d5df8",
          "latitude": 30.6197699181112,
          "longitude": -96.3381758545864,
          "stop": {
            "name": "Ross and Bizzell - South",
            "stopCode": "0014",
            "stopType": 0
          }
        },
        {
          "key": "7979589a-46f3-4cad-a1a2-d0fddd443b76",
          "latitude": 30.6198967586747,
          "longitude": -96.3380442693026,
          "stop": null
        },
        {
          "key": "c8ce2513-d399-4731-8baf-27bbd38c81de",
          "latitude": 30.6201187145781,
          "longitude": -96.337676724057,
          "stop": null
        },
        {
          "key": "1a5e5fc2-8d02-42c6-aaa5-de804522299a",
          "latitude": 30.6201991808533,
          "longitude": -96.3375251792386,
          "stop": null
        },
        {
          "key": "e7fe2550-b1e4-4192-b47e-b87868720d59",
          "latitude": 30.6203534078809,
          "longitude": -96.336932411011,
          "stop": null
        },
        {
          "key": "bea48b40-f5bc-497e-b797-652768b9a248",
          "latitude": 30.6203668189268,
          "longitude": -96.3365662894586,
          "stop": null
        },
        {
          "key": "d3015b9e-4c82-47c2-85c3-72f5777f1d62",
          "latitude": 30.6203306091029,
          "longitude": -96.336233695521,
          "stop": null
        },
        {
          "key": "8bbbdd0e-7457-47e8-a07d-b0f456751c89",
          "latitude": 30.6202032041671,
          "longitude": -96.3358005187392,
          "stop": null
        },
        {
          "key": "bd30b427-14a6-48b6-ae9e-381f14f2abf1",
          "latitude": 30.6199752163872,
          "longitude": -96.3353740474805,
          "stop": null
        },
        {
          "key": "60795bc6-d1e3-42aa-8c9f-679530aefcb8",
          "latitude": 30.6197217476202,
          "longitude": -96.335060229007,
          "stop": null
        },
        {
          "key": "d2f163ca-a44c-48ad-b0f6-974a4f4cf27f",
          "latitude": 30.6193931769963,
          "longitude": -96.33480676024,
          "stop": null
        },
        {
          "key": "f42fd1fc-8f17-41cd-8ddc-0688089a5112",
          "latitude": 30.6188553940568,
          "longitude": -96.3346042534473,
          "stop": null
        },
        {
          "key": "e7cd9c1e-baac-4946-aefa-f4ec48981de6",
          "latitude": 30.6184745203539,
          "longitude": -96.3346002301336,
          "stop": null
        },
        {
          "key": "ba1cbcec-106c-4eb2-a130-94e9d679c7b1",
          "latitude": 30.6181218098474,
          "longitude": -96.3346686264675,
          "stop": null
        },
        {
          "key": "fc7b0e43-1198-4155-a415-ae143999b680",
          "latitude": 30.6178817521263,
          "longitude": -96.3347933491941,
          "stop": null
        },
        {
          "key": "bef7f2a8-c404-41c7-ab1b-0b86c7ad7631",
          "latitude": 30.617385543429,
          "longitude": -96.3351715406878,
          "stop": null
        },
        {
          "key": "2867e14f-45b1-4cef-b1b2-0fe5a36c4aee",
          "latitude": 30.6171749900088,
          "longitude": -96.3352573713814,
          "stop": null
        },
        {
          "key": "5a331dd6-dcc7-4fd8-a714-affd93bab4fa",
          "latitude": 30.6169684599023,
          "longitude": -96.3352801701594,
          "stop": null
        },
        {
          "key": "28e79269-c4fc-431d-8bb1-5c647a9a66ed",
          "latitude": 30.6167123089261,
          "longitude": -96.335190316152,
          "stop": null
        },
        {
          "key": "33bffb35-5cad-4221-a8ab-0aa206296741",
          "latitude": 30.6154492906108,
          "longitude": -96.3341193311432,
          "stop": {
            "name": "Southside Rec Center",
            "stopCode": "0008",
            "stopType": 0
          }
        },
        {
          "key": "547d5ef8-d9cc-44c1-8494-8d3e0f62baba",
          "latitude": 30.6135285266357,
          "longitude": -96.332274754779,
          "stop": null
        },
        {
          "key": "9272c861-0eba-4385-8618-8b412e88c0c5",
          "latitude": 30.6113823030142,
          "longitude": -96.335566148705,
          "stop": {
            "name": "Lewis Street",
            "stopCode": "0020",
            "stopType": 0
          }
        },
        {
          "key": "43f22ebe-d636-4401-b1d2-6a652c3841f7",
          "latitude": 30.6109965211747,
          "longitude": -96.3360204598916,
          "stop": null
        },
        {
          "key": "85cab531-f447-43c6-81df-07c4ed5140cb",
          "latitude": 30.6135218211128,
          "longitude": -96.3383405708278,
          "stop": null
        },
        {
          "key": "5327e02b-3561-4b19-847d-c238792add69",
          "latitude": 30.6136461377371,
          "longitude": -96.3382897685532,
          "stop": null
        },
        {
          "key": "606253de-d3a2-4a09-a2fb-493559ff3cc6",
          "latitude": 30.6137173298845,
          "longitude": -96.3383015859656,
          "stop": null
        },
        {
          "key": "ed35381a-d1fc-4bbc-b8a5-c36f50b4a031",
          "latitude": 30.6142835685184,
          "longitude": -96.3387764298186,
          "stop": null
        },
        {
          "key": "9a98df4e-21c1-43e3-86f7-8cc42ba9e51c",
          "latitude": 30.6151796293546,
          "longitude": -96.3373712838717,
          "stop": {
            "name": "Commons",
            "stopCode": "0100",
            "stopType": 0
          }
        }
      ],
      "segmentPaths": []
    },
    {
      "patternKey": "eb990af4-b5f7-4d8f-9cae-bb4b92ce0880",
      "directionKey": "90910ebf-50db-4a93-96a4-680e43eb7a83",
      "patternPoints": [
        {
          "key": "7648ac4b-6253-454d-89c1-72b42b087b22",
          "latitude": 30.6151796293546,
          "longitude": -96.3373712838717,
          "stop": {
            "name": "Commons",
            "stopCode": "0100",
            "stopType": 0
          }
        },
        {
          "key": "7d08edb5-3375-45e6-a8d9-91963fe90de5",
          "latitude": 30.6167753408417,
          "longitude": -96.3350763222621,
          "stop": null
        },
        {
          "key": "b3d70a09-7afd-45db-a15c-7f54a34723c3",
          "latitude": 30.6169738243207,
          "longitude": -96.3351527652236,
          "stop": null
        },
        {
          "key": "03dce568-bdc6-4128-bfd7-6b473d503c31",
          "latitude": 30.6173131237813,
          "longitude": -96.3350481590657,
          "stop": null
        },
        {
          "key": "319d977a-b711-4b5c-97c4-0c37cb2bc580",
          "latitude": 30.6178348134658,
          "longitude": -96.334653874317,
          "stop": null
        },
        {
          "key": "59b16860-046c-4989-bc59-693d21b1fcb4",
          "latitude": 30.6184463571576,
          "longitude": -96.3344808718253,
          "stop": null
        },
        {
          "key": "a80928cd-c91e-4c0e-a9fc-2f1c518d1b42",
          "latitude": 30.6188688051026,
          "longitude": -96.3344902595574,
          "stop": null
        },
        {
          "key": "835b808c-557b-42d1-9b72-8c0793ff9c93",
          "latitude": 30.6193314861853,
          "longitude": -96.3346337577482,
          "stop": null
        },
        {
          "key": "a6271747-3057-420b-8058-f51757ad772b",
          "latitude": 30.619664080123,
          "longitude": -96.334845652273,
          "stop": null
        },
        {
          "key": "b4e589ea-a5bb-4372-aac2-805befc5a617",
          "latitude": 30.620102621323,
          "longitude": -96.3353552720162,
          "stop": null
        },
        {
          "key": "dc4e692c-faa5-4170-900e-00f3ef823cd3",
          "latitude": 30.6204164397965,
          "longitude": -96.3361237249448,
          "stop": null
        },
        {
          "key": "4777fbff-6bf9-4c18-a1b5-beaa4268993d",
          "latitude": 30.6204660606662,
          "longitude": -96.3368734024092,
          "stop": null
        },
        {
          "key": "ad955edd-892a-4e5a-96bf-5625807b7678",
          "latitude": 30.6202930581744,
          "longitude": -96.3375654123762,
          "stop": null
        },
        {
          "key": "d3be0ea8-d7c1-4683-8869-c9ee188088d2",
          "latitude": 30.6199188899946,
          "longitude": -96.3381997548461,
          "stop": null
        },
        {
          "key": "13b1b5e5-d2a2-4d6f-a56d-e0f18c678ba1",
          "latitude": 30.6197899772495,
          "longitude": -96.3383278872089,
          "stop": null
        },
        {
          "key": "111e4116-dd06-4be0-9608-34bc0b4c6e1a",
          "latitude": 30.619765098949,
          "longitude": -96.3383845376723,
          "stop": {
            "name": "Ross and Bizzell - North",
            "stopCode": "0012",
            "stopType": 0
          }
        },
        {
          "key": "f6d00456-01ec-486c-924e-3a6fd6a1b604",
          "latitude": 30.6196908229636,
          "longitude": -96.3384224265082,
          "stop": null
        },
        {
          "key": "0afc3f7b-244b-4c54-94d1-d5f3fdc1bb55",
          "latitude": 30.617907530947,
          "longitude": -96.3411604370512,
          "stop": {
            "name": "Ross and Ireland - North",
            "stopCode": "0016",
            "stopType": 0
          }
        },
        {
          "key": "b6f7eff2-950d-413b-85e4-ce5a301b4dcd",
          "latitude": 30.6168423960711,
          "longitude": -96.3424993361532,
          "stop": null
        },
        {
          "key": "fb597b00-b683-4882-a2d5-aeac98b40aeb",
          "latitude": 30.617770168978,
          "longitude": -96.3433212438803,
          "stop": {
            "name": "Asbury Water Tower",
            "stopCode": "0400",
            "stopType": 0
          }
        },
        {
          "key": "d3e6c653-4114-4e55-b554-670c0cfdcd8e",
          "latitude": 30.61910483951,
          "longitude": -96.3446129169829,
          "stop": null
        },
        {
          "key": "7870f2ab-3895-478e-8027-ab272bf53b4a",
          "latitude": 30.6166009972454,
          "longitude": -96.3474587409174,
          "stop": null
        },
        {
          "key": "438863f7-ad08-4f84-b31c-cd7a6d65751b",
          "latitude": 30.615451670614,
          "longitude": -96.349117687292,
          "stop": null
        },
        {
          "key": "fd16daa9-16bf-4dc6-acee-541c4be734f7",
          "latitude": 30.6146282323973,
          "longitude": -96.3500604838169,
          "stop": null
        },
        {
          "key": "eb5c9a9f-4e96-4321-94d5-6df16c70a083",
          "latitude": 30.6137887009256,
          "longitude": -96.3508383244776,
          "stop": null
        },
        {
          "key": "2dc4d475-f286-4281-a70e-d1901a66e54d",
          "latitude": 30.6127037473144,
          "longitude": -96.3501516789288,
          "stop": null
        },
        {
          "key": "c7077815-a1da-4e96-acd7-f689af352aeb",
          "latitude": 30.6122987337291,
          "longitude": -96.3499250322536,
          "stop": null
        },
        {
          "key": "c0da7cfb-a33e-43f1-ae5c-7bde25150f11",
          "latitude": 30.6120345361253,
          "longitude": -96.3497185021471,
          "stop": null
        },
        {
          "key": "6606c035-f977-4e00-bddc-c9947bbb2b48",
          "latitude": 30.611860192529,
          "longitude": -96.3495602518058,
          "stop": null
        },
        {
          "key": "b377cf56-b74b-41fd-8fdb-39b9b849b5f7",
          "latitude": 30.6117609507895,
          "longitude": -96.3493724971636,
          "stop": null
        },
        {
          "key": "c80a1eb2-981f-4622-af66-67d6a6ef4e70",
          "latitude": 30.6118481225877,
          "longitude": -96.349156579325,
          "stop": null
        },
        {
          "key": "1e9a9ddf-0255-4a67-b81c-f0bfb0a44893",
          "latitude": 30.6124113865144,
          "longitude": -96.3483103423304,
          "stop": null
        },
        {
          "key": "230adb12-e7f3-4b5c-b592-1b4a8a1f8077",
          "latitude": 30.6119549738719,
          "longitude": -96.3479654681912,
          "stop": {
            "name": "HEEP",
            "stopCode": "0108",
            "stopType": 0
          }
        },
        {
          "key": "4eb74413-3498-4ee3-ac28-32f4d4437766",
          "latitude": 30.6102106338865,
          "longitude": -96.3463201431227,
          "stop": null
        },
        {
          "key": "6cf78c81-031e-4c6b-862b-6fb93952ff87",
          "latitude": 30.6098530669729,
          "longitude": -96.346967337918,
          "stop": {
            "name": "Kleberg - Outbound",
            "stopCode": "0030",
            "stopType": 0
          }
        },
        {
          "key": "e2cd07f5-1b66-4e79-92cc-4ab7c46bbf1b",
          "latitude": 30.6095776325212,
          "longitude": -96.3472575752293,
          "stop": null
        },
        {
          "key": "d47fda3d-4257-46ff-8a50-0ce0f49b16a5",
          "latitude": 30.6068107814179,
          "longitude": -96.3448405209504,
          "stop": {
            "name": "Rec Center",
            "stopCode": "0112",
            "stopType": 0
          }
        },
        {
          "key": "38ca5834-87af-4c82-8acd-f91a889dceab",
          "latitude": 30.6064179901134,
          "longitude": -96.3444037046673,
          "stop": null
        },
        {
          "key": "d832c737-4346-4b16-b8fe-cf8ff6b37fa7",
          "latitude": 30.606012976528,
          "longitude": -96.3450139072546,
          "stop": null
        },
        {
          "key": "53680698-4478-4da1-a73c-9a1f9eab12b6",
          "latitude": 30.6055246626314,
          "longitude": -96.3452442193381,
          "stop": {
            "name": "Lot 100G",
            "stopCode": "0114",
            "stopType": 0
          }
        },
        {
          "key": "187ce2cf-4e0d-41b1-8cbe-6358c9d08c4c",
          "latitude": 30.6053632325095,
          "longitude": -96.3452322104127,
          "stop": null
        },
        {
          "key": "74c7388c-dae8-493f-8a5f-cea2b7969cf6",
          "latitude": 30.6048368724944,
          "longitude": -96.346023977045,
          "stop": null
        },
        {
          "key": "bd6f7e3d-4e8e-4550-b7b3-05789b42e260",
          "latitude": 30.6048139872115,
          "longitude": -96.3461185163442,
          "stop": null
        },
        {
          "key": "765de048-e25e-43c6-bd66-3186e01be8d3",
          "latitude": 30.604928413572,
          "longitude": -96.3472707140554,
          "stop": null
        },
        {
          "key": "79caff37-1787-41cd-bb23-ca53a4f12c57",
          "latitude": 30.6051734450563,
          "longitude": -96.3475043384734,
          "stop": null
        },
        {
          "key": "c821326d-6b95-4c80-aa17-84a4572c9ac0",
          "latitude": 30.6056067816196,
          "longitude": -96.3474036244909,
          "stop": {
            "name": "Reed Arena",
            "stopCode": "0050",
            "stopType": 0
          }
        }
      ],
      "segmentPaths": []
    }
  ],
  "vehiclesByDirections": null
}
*/
class PatternPathReturn {
  String routeKey;
  List<PatternPath> patternPaths;

  PatternPathReturn({required this.routeKey, required this.patternPaths});

  factory PatternPathReturn.fromJson(Map<String, dynamic> json) {
    return PatternPathReturn(
      routeKey: json['routeKey'],
      patternPaths: json['patternPaths']
          .map<PatternPath>((e) => PatternPath.fromJson(e))
          .toList(),
    );
  }
}

Future<List<PatternPath>> getPatternPaths(List<String> routeKeys) async {
  print({for (var (i, p) in routeKeys.indexed) "count[$i]": p});
  List<PatternPath> paths = [];
  await post(
          Uri(
            scheme: 'https',
            host: HOST,
            path: 'RouteMap/GetPatternPaths',
          ),
          body: {for (var (i, p) in routeKeys.indexed) "routeKeys[$i]": p})
      .then((value) {
    print("called");
    print(value);
    paths.addAll((jsonDecode(value.body) as List<dynamic>)
        .map((e) => PatternPathReturn.fromJson(e).patternPaths)
        .expand((element) => element));
  });
  return paths;
}

Future<List<BusRouteVehicle>> getBuses(List<String> routeKeys) async {
  List<BusRouteVehicle> buses = [];
  print("getting buses called");
  await post(
          Uri(
            scheme: 'https',
            host: HOST,
            path: 'RouteMap/GetVehicles',
          ),
          body: {for (var (i, p) in routeKeys.indexed) "routeKeys[$i]": p})
      .then((value) {
    buses.addAll((jsonDecode(value.body) as List<dynamic>)
        .map((e) => BusRouteVehicle.fromJson(e)));
  });
  print(buses);
  return buses;
}
