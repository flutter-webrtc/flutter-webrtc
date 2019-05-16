package com.cloudwebrtc.webrtc.utils;

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

    public int size(){
        return mArray.size();
    }

    public boolean isNull(int index){
        return mArray.get(index) == null;
    }

    public boolean getBoolean(int index){
        return (Boolean) mArray.get(index);
    }

    public double getDouble(int index){
        return (double) mArray.get(index);
    }

    public int getInt(int index){
        return (int) mArray.get(index);
    }

    public String getString(int index){
        return (String) mArray.get(index);
    }

    public Byte[] getByte(int index){
        return (Byte[]) mArray.get(index);
    }

    public ConstraintsArray getArray(int index){
        return new ConstraintsArray((ArrayList<Object>)mArray.get(index));
    }

    public ConstraintsMap getMap(int index){
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
        } else if (object instanceof Byte) {
            return ObjectType.Byte;
        }
        return ObjectType.Null;
    }

    public ArrayList<Object> toArrayList(){
        return mArray;
    }

    public void pushNull(){
        mArray.add(null);
    }

    public void pushBoolean(boolean value){
        mArray.add(value);
    }

    public void pushDouble(double value){
        mArray.add(value);
    }

    public void pushInt(int value){
        mArray.add(value);
    }

    public void pushString(String value){
        mArray.add(value);
    }

    public void pushArray(ConstraintsArray array){
        mArray.add(array.toArrayList());
    }

    public void pushByte(byte[] value){
        mArray.add(value);
    }

    public void pushMap(ConstraintsMap map){
        mArray.add(map.toMap());
    }

}
