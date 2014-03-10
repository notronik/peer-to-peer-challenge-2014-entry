part of p2pentry;

class MathUtils {
    static double roundTo(double val, double measure){
        return (val*measure).round()/measure;
    }
}