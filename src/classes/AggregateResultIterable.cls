public without sharing class AggregateResultIterable implements Iterable<AggregateResult> {
    private List<AggregateResult> results;
    private Integer batchSize;

    public AggregateResultIterable(String soql, Integer batchSize) {
        System.debug('soql->' + soql);
        this.results = Database.query(soql);
        this.batchSize = batchSize;
    }

    public Iterator<AggregateResult> iterator() {
        return new AggregateResultIterator(results, batchSize);
    }

    public class AggregateResultIterator implements Iterator<AggregateResult> {
        private List<AggregateResult> results;
        private Integer batchSize;
        private Integer currentIndex = 0;

        public AggregateResultIterator(List<AggregateResult> results, Integer batchSize) {
            this.results = results;
            this.batchSize = batchSize;
        }

        public Boolean hasNext() {
            return currentIndex < results.size();
        }

        public AggregateResult next() {
            return results[currentIndex++];
        }
    }
}