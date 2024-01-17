({
    convertMapToList: function(map) {
        var list = [];
        for (var key in map) {
            if (map.hasOwnProperty(key)) {
                list.push({ key: key, value: map[key] });
            }
        }
        return list;
    }
})
