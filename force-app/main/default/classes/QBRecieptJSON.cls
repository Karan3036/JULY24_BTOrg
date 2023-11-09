public class QBRecieptJSON {
    public class MetaData{
        public String CreateTime;
        public String LastUpdatedTime;
    }

    public class CurrencyRef{
    	public String value;
		public String name;
    }

    public class LinkedTxn{
        public String TxnId;
        public String TxnType;
    }

    public class Line{
        public Double Amount;
        public LinkedTxn LinkedTxn;
        public LineEx LineEx;
    }

    public class LineEx{
        public NameValue NameValue;
    }

    public class NameValue{
        public String Name;
        public String Value;
    }

    public class CustomerRef{
        public String name;
        public String value;
    }

    public class Payment{
        public String Id;
        public String domain;
		public Boolean sparse;
        public String SyncToken;
        public MetaData MetaData;
        public CurrencyRef CurrencyRef;
        public String TxnDate;
        public Line Line;
        public CustomerRef CustomerRef;
        public String DepositToAccountRef;
        public Double TotalAmt;
        public Double UnappliedAmt;
        public Boolean ProcessPayment;
        public LinkedTxn LinkedTxn;
    }

    public static QBRecieptJSON parse(String json) {
        return (QBRecieptJSON) System.JSON.deserialize(json, QBRecieptJSON.class);
    }

    public static QBRecieptJSON.Payment parseCustomer(String json) {
        return (QBRecieptJSON.Payment) System.JSON.deserialize(json, QBRecieptJSON.Payment.class);
}
}