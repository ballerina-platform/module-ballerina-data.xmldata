package io.ballerina.stdlib.data.xml;

import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.runtime.api.values.BXml;
import io.ballerina.stdlib.data.utils.DataUtils;

import java.io.ByteArrayInputStream;
import java.io.InputStreamReader;
import java.io.StringReader;

/**
 * Xml conversion.
 *
 * @since 0.1.0
 */
public class Native {

    public static Object fromXmlWithType(BXml xml, BMap<BString, Object> map, BTypedesc typed) {
        return null;
    }

    public static Object fromXmlStringWithType(Object xml, BMap<BString, Object> map, BTypedesc typed) {
        try {
            if (xml instanceof BString) {
                return XmlParser.parse(new StringReader(((BString) xml).getValue()), typed.getDescribingType());
            } else if (xml instanceof BArray) {
                byte[] bytes = ((BArray) xml).getBytes();
                return XmlParser.parse(
                        new InputStreamReader(new ByteArrayInputStream(bytes)), typed.getDescribingType());
            } else if (xml instanceof BStream) {
                return null;
            } else {
                return DataUtils.getError("invalid input type");
            }
        } catch (Exception e) {
            return DataUtils.getError(e.getMessage());
        }
    }
}
