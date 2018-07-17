/* A function for reading from APIs to give feedback on forms.
 *
 * Assumes that the element given as input is a div that contains an `input`
 * element and `div.feedback` that will contain the feedback `fail_message`
 * and a font-awesome element.
 * */

export default function (element, api_endpoint, func) {
  if (!element) return;

  const input = element.querySelector('input')
  const feedback = element.querySelector('div.feedback')
  console.log(input, feedback)

  input.addEventListener('change', function(event) {
    const value = event.target.value

    if (value.length) {
      let req = new XMLHttpRequest()
      console.log(value)

      req.onreadystatechange = function () {
        if (req.readyState === XMLHttpRequest.DONE && req.status === 200) {
          func(JSON.parse(req.responseText))
        }
      }
      req.open("GET", api_endpoint + "?value=" + value, true)
      req.send()
    }
  })
}
