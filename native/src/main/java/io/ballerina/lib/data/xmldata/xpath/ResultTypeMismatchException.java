package io.ballerina.lib.data.xmldata.xpath;

import io.ballerina.runtime.api.types.Type;

/**
 * Exception thrown when there is a mismatch between the expected and actual
 * result type in XPath operations.
 */
public class ResultTypeMismatchException extends Exception {

    public ResultTypeMismatchException(Object value, Type targetType) {
        super(errorMessage(value, targetType));
    }

    private static String errorMessage(Object value, Type targetType) {
        return "Value: " + value + " cannot be converted to type: " + targetType;
    }
}
