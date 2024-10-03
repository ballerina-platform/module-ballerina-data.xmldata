/*
 *  Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com).
 *
 *  WSO2 LLC. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

package io.ballerina.lib.data.xmldata.io;

import io.ballerina.lib.data.xmldata.utils.DiagnosticErrorCode;
import io.ballerina.lib.data.xmldata.utils.DiagnosticLog;
import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.async.StrandMetadata;
import io.ballerina.runtime.api.types.MethodType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.Map;
import java.util.concurrent.Semaphore;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Java Input Stream based on Ballerina byte block stream. <code>stream<byte[], error?></code>
 *
 * @since 0.1.0
 */
public class BallerinaByteBlockInputStream extends InputStream {

    private final BObject iterator;
    private final Environment env;
    private final String nextMethodName;
    private final Type returnType;
    private final String strandName;
    private final StrandMetadata metadata;
    private final Map<String, Object> properties;
    private final AtomicBoolean done = new AtomicBoolean(false);
    private final MethodType closeMethod;

    private byte[] currentChunk = new byte[0];
    private int nextChunkIndex = 0;

    public BallerinaByteBlockInputStream(Environment env, BObject iterator, MethodType nextMethod,
                                         MethodType closeMethod) {
        this.env = env;
        this.iterator = iterator;
        this.nextMethodName = nextMethod.getName();
        this.returnType = nextMethod.getReturnType();
        this.closeMethod = closeMethod;
        this.strandName = env.getStrandName().orElse("");
        this.metadata = env.getStrandMetadata();
        this.properties = Map.of();
    }

    @Override
    public int read() {
        if (done.get()) {
            return -1;
        }
        if (hasBytesInCurrentChunk()) {
            return currentChunk[nextChunkIndex++];
        }
        // Need to get a new block from the stream, before reading again.
        nextChunkIndex = 0;
        try {
            if (readNextChunk()) {
                return read();
            }
        } catch (InterruptedException e) {
            BError error = DiagnosticLog.error(DiagnosticErrorCode.CAN_NOT_READ_STREAM);
            return -1;
        }
        return -1;
    }

    @Override
    public void close() throws IOException {
        super.close();
        Semaphore semaphore = new Semaphore(0);
        if (closeMethod != null) {
            env.getRuntime().call(iterator, closeMethod.getName());
        }
    }

    private boolean hasBytesInCurrentChunk() {
        return currentChunk.length != 0 && nextChunkIndex < currentChunk.length;
    }

    private boolean readNextChunk() throws InterruptedException {
        try {
            Object result = env.getRuntime().call(iterator, nextMethodName);
            if (result == null) {
                done.set(true);
                return true;
            }
            if (result instanceof BMap<?, ?>) {
                BMap<BString, Object> valueRecord = (BMap<BString, Object>) result;
                final BString value = Arrays.stream(valueRecord.getKeys()).findFirst().get();
                final BArray arrayValue = valueRecord.getArrayValue(value);
                currentChunk = arrayValue.getByteArray();
            } else {
                done.set(true);
                return true;
            }
        } catch (BError bError) {
            done.set(true);
            return true;
        }
        return !done.get();
    }
}
