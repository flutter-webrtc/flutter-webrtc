package com.cloudwebrtc.webrtc;

import java.util.ArrayList;
import java.util.Map;

public class ConstraintsArray {

    final private  ArrayList<Object> mArray;

    public ConstraintsArray(){
        this.mArray = new ArrayList<>();
    }

    public ConstraintsArray(ArrayList<Object> array){
     this.mArray = array;
    }

    int size(){
        return mArray.size();
    }

    boolean isNull(int index){
        return mArray.get(index) == null;
    }

    boolean getBoolean(int index){
        return (Boolean) mArray.get(index);
    }

    double getDouble(int index){
        return (double) mArray.get(index);
    }

    int getInt(int index){
        return (int) mArray.get(index);
    }

    String getString(int index){
        return (String) mArray.get(index);
    }

    ConstraintsArray getArray(int index){
        return new ConstraintsArray((ArrayList<Object>)mArray.get(index));
    }

    ConstraintsMap getMap(int index){
        return new ConstraintsMap((Map<String, Object>) mArray.get(index));
    }

    public ObjectType getType(int index) {
        Object object = mArray.get(index);

        if (object == null) {
            return ObjectType.Null;
        } else if (object instanceof Boolean) {
            return ObjectType.Boolean;
        } else if (object instanceof Double ||
                object instanceof Float ||
                object instanceof Integer) {
            return ObjectType.Number;
        } else if (object instanceof String) {
            return ObjectType.String;
        } else if (object instanceof ArrayList) {
            return ObjectType.Array;
        } else if (object instanceof Map) {
            return ObjectType.Map;
        }
        return null;
    }

    ArrayList<Object> toArrayList(){
        return mArray;
    }

    void pushNull(){
        mArray.add(null);
    }

    void pushBoolean(boolean value){
        mArray.add(value);
    }

    void pushDouble(double value){
        mArray.add(value);
    }

    void pushInt(int value){
        mArray.add(value);
    }

    void pushString(String value){
        mArray.add(value);
    }

    void pushArray(ConstraintsArray array){
        mArray.add(array.toArrayList());
    }

    void pushMap(ConstraintsMap map){
        mArray.add(map.toMap());
    }

}
