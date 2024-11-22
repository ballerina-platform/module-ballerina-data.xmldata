// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/data.xmldata;

string xmlStr = string `<Data><A>1</A><B>2</B></Data>`;

record {|
    @xmldata:Name {
        value: "B"
    }
    string A;
    string B;
|}|map<int>|error rec1 = xmldata:parseString(xmlStr);

record {|
    @xmldata:Name {
        value: "B"
    }
    string A;
    string B;
|}|map<int>|error rec2 = {A: "1", B: "2"};

public function main() {
    record {|
        @xmldata:Name {
            value: "B"
        }
        string A;
        string B;
    |}|map<int>|error rec3 = xmldata:parseString(xmlStr);

    record {|
        @xmldata:Name {
            value: "B"
        }
        string A;
        string B;
    |}|map<int>|error rec4 = {A: "1", B: "2"};
}
