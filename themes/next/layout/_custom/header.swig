
<div class="switch-box">
  <input id="checked_1" type="checkbox" class="switch"  value="0"0 />
  <label for="checked_1">
  <script>
  (function(){
    var dark = document.getElementById('checked_1')
    var theme = window.localStorage.getItem('theme')
    var darkMedia = window.matchMedia('(prefers-color-scheme: dark)')
    function darkModeListener() {
      console.log(darkMedia.matches)
      dark.checked = !!darkMedia.matches
    }
    darkMedia.addListener(darkModeListener)
    if(theme==='dark'){
      dark.checked = true
    }else if(theme==='light'){
      dark.checked = false
    }else {
      darkModeListener()
    }
    dark.onclick = (e)=>{window.localStorage.setItem('theme',e.target.checked ? 'dark' : 'light')}
  })()
  </script>
    <dark-bg></dark-bg>
    <dark-mode></dark-mode>
  </label>
</div>
