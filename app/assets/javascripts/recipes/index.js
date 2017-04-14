
function handleSearchTyping() {
  
  // get text in the input now
  var text = $('input.search-recipe-input').val();
  //console.log(text);
  updatePage([".recipes-status-all", ".recipe-tiles"], {params: {filter: text}});
}
