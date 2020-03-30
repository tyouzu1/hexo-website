
<div class="switch-box">
  <input id="checked_1" type="checkbox" class="switch"  value="0" />
  <label for="checked_1">
  <script>
  (function(){
    var dark = document.getElementById('checked_1')
    var body = document.body
    var theme = window.localStorage.getItem('theme')
    var darkMedia = window.matchMedia('(prefers-color-scheme: dark)')
    function darkModeListener() {
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
    bodyDarkToggle(dark.checked)
    dark.onclick = (e)=>{
      window.localStorage.setItem('theme',e.target.checked ? 'dark' : 'light')
      bodyDarkToggle(e.target.checked)
    }
    function bodyDarkToggle(checked){
      if(checked){
        body.classList.add('dark') 
      }else {
       body.classList.remove('dark')
      }
    }
  })()
  </script>
    <dark-bg></dark-bg>
    <dark-mode></dark-mode>
  </label>
</div>
