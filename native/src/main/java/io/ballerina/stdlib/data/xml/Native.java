package io.ballerina.stdlib.data.xml;

import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.runtime.api.values.BXml;
import io.ballerina.stdlib.data.utils.DataUtils;

import java.io.StringReader;

/**
 * Xml conversion.
 *
 * @since 0.1.0
 */
public class Native {

    public static Object fromXmlByteArrayWithType(BArray byteArr, BMap<BString, Object> map, BTypedesc typed) {
        return null;
    }

    public static Object fromXmlByteStreamWithType(BStream byteStream, BMap<BString, Object> map, BTypedesc typed) {
        return null;
    }

    public static Object fromXmlWithType(BXml xml, BMap<BString, Object> map, BTypedesc typed) {
        return null;
    }

    public static Object fromXmlStringWithType(BString xml, BMap<BString, Object> map, BTypedesc typed) {
        try {
            return XmlParser.parse(new StringReader(xml.getValue()), typed.getDescribingType());
        } catch (Exception e) {
            return DataUtils.getError(e.getMessage());
        }
    }
}
