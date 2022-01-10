package com.cloudwebrtc.webrtc.utils;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.Map;

public class ConstraintsArray {

    private final ArrayList<Object> mArray;

    public ConstraintsArray(){
        mArray = new ArrayList<>();
    }

    public ConstraintsArray(ArrayList<Object> array){
        mArray = array;
    }

    public int size(){
        return mArray.size();
    }

    @NonNull
    public String getString(int index){
        return (String) mArray.get(index);
    }

    @NonNull
    public ConstraintsMap getMap(int index){
        return new ConstraintsMap((Map<String, Object>) mArray.get(index));
    }

    @NonNull
    public ObjectType getType(int index) {
        Object value = mArray.get(index);

        if (value instanceof Boolean) {
            return ObjectType.Boolean;
        } else if (value instanceof Double
                || value instanceof Float
                || value instanceof Integer) {
            return ObjectType.Number;
        } else if (value instanceof String) {
            return ObjectType.String;
        } else if (value instanceof ArrayList) {
            return ObjectType.Array;
        } else if (value instanceof Map) {
            return ObjectType.Map;
        } else {
            throw new IllegalArgumentException(
                    String.format(
                            "Invalid value %s for index %s contained in ConstraintsArray",
                            value, index));
        }
    }

    public ArrayList<Object> toArrayList(){
        return mArray;
    }

    public void pushMap(@NonNull ConstraintsMap map){
        mArray.add(map.toMap());
    }
}
