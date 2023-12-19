/*
 * Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.data.xmldata.compiler;

import io.ballerina.projects.DiagnosticResult;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;
import org.testng.Assert;
import org.testng.annotations.Test;

import java.util.List;
import java.util.stream.Collectors;

/**
 * This class includes tests for Ballerina Xmldata compiler plugin.
 */
public class CompilerPluginTest {
    @Test
    public void testDuplicateFieldNegative1() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_1").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 1);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(),
                "invalid field: duplicate field found");
    }

    @Test
    public void testDuplicateFieldNegative2() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_2").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 1);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(),
                "invalid field: duplicate field found");
    }

    @Test
    public void testUnsupportedUnionTypeNegative1() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_3").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 2);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple non-primitive record types");
        Assert.assertEquals(errorDiagnosticsList.get(1).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple non-primitive record types");
    }

    @Test
    public void testUnsupportedUnionTypeNegative2() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_4").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 2);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple non-primitive record types");
        Assert.assertEquals(errorDiagnosticsList.get(1).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple non-primitive record types");
    }

    @Test
    public void testUnsupportedTypeNegative1() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_5").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 4);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple non-primitive record types");
        Assert.assertEquals(errorDiagnosticsList.get(1).diagnosticInfo().messageFormat(),
                "unsupported type: the record field does not support the expected type");
        Assert.assertEquals(errorDiagnosticsList.get(2).diagnosticInfo().messageFormat(),
                "unsupported type: the record field does not support the expected type");
        Assert.assertEquals(errorDiagnosticsList.get(3).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple non-primitive record types");
    }

    @Test
    public void testUnsupportedTypeNegative2() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_8").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 8);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple non-primitive record types");
        Assert.assertEquals(errorDiagnosticsList.get(1).diagnosticInfo().messageFormat(),
                "unsupported type: the record field does not support the expected type");
        Assert.assertEquals(errorDiagnosticsList.get(2).diagnosticInfo().messageFormat(),
                "unsupported type: the record field does not support the expected type");
        Assert.assertEquals(errorDiagnosticsList.get(3).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple non-primitive record types");
        Assert.assertEquals(errorDiagnosticsList.get(4).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple non-primitive record types");
        Assert.assertEquals(errorDiagnosticsList.get(5).diagnosticInfo().messageFormat(),
                "unsupported type: the record field does not support the expected type");
        Assert.assertEquals(errorDiagnosticsList.get(6).diagnosticInfo().messageFormat(),
                "unsupported type: the record field does not support the expected type");
        Assert.assertEquals(errorDiagnosticsList.get(7).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple non-primitive record types");
    }

    @Test
    public void testChildRecordWithNameAnnotNegative() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_6").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.WARNING))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 1);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(),
                "invalid annotation attachment: child record does not allow name annotation");
    }
}
