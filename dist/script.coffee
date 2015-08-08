delay = (->
  timer = 0
  (callback, ms) ->
    clearTimeout timer
    timer = setTimeout(callback, ms)
)()

process_markdown = ->
  $.post("http://rubymarkdownbattle.herokuapp.com/",
    {
      options: $("#options").serialize(),
      text: $("#markdown > textarea").val()
    },
    (data, textStatus, jqXHR) ->
      $("#html").html(data["renderHTML"])
      $("#render-time").html("render time: #{parseFloat(data["renderTime"]).toFixed(2)} ms")
    , "json")


$ ->
  # render greeting
  process_markdown()

  # debounce markdown prcessing on typing
  $("#markdown > textarea").keydown ->
    delay (->
      process_markdown()
    ), 1000

  # reprocess on options change
  $("form table input").change ->
    process_markdown()

  $("#processor").change ->

    # ensure processing on processor change
    process_markdown()

    # hide all options for all processors
    for processor in $("#processor option")
      $("#" + processor.value).hide()

    # show the right one
    processor = $("#processor option:selected").val()
    $("#" + processor).show()

  $("#about").click ->
    $("#markdown > textarea").val(about)
    $("#processor").val("redcarpet").change()
    $("[name='redcarpet:autolink']").attr('checked', true)
    $("[name='redcarpet:lax_spacing']").attr('checked', true)
    $("[name='redcarpet:tables']").attr('checked', true).change()


about = """
        Ruby Markdown Battle
        ====================

        Why?
        ----
        Ruby Markdown Battle was created so that I could easily compare and contrast Ruby Markdown implementations and determine which one was the most suited for my needs. It evolved from a series of scripts into this website.

        What?
        -----
        The four gems that are currently compared here are:
        * redcarpet: https://github.com/vmg/redcarpet
        * rdiscount: https://github.com/davidfstr/rdiscount
        * kramdown: https://github.com/gettalong/kramdown
        * maruku: https://github.com/bhollis/maruku

        And?
        ----
        Here is a simplified list of features that I've compared and taken into account for my applications:

        |           | LaTeX | Easily Extensible | Markdown Extra |
        |-----------|:-----:|:-----------------:|:--------------:|
        | redcarpet |       |         X         |        X       |
        | rdiscount |       |                   |        X       |
        | kramdown  |   X   |                   |        X       |
        | maruku    |   X   |                   |        X       |

        Each implementation had something notable to mention:
        <dl>
          <dt>Redcarpet</dt>
          <dd>Maintained by Github</dd>
          <dd>Uses Sundown Processor</dd>
          <dd>Standalone SmartyPants Implementation</dd>

          <dt>RDiscount</dt>
          <dd>Uses Discount Processor</dd>

          <dt>Kramdown</dt>
          <dd>Built in CodeRay integration</dd>
          <dd>All PHP Markdown Extra Features</dd>

          <dt>Maruku</dt>
          <dd>Inline Latex Math</dd>
          <dd>All PHP Markdown Extra Features</dd>  
        </dl>


        Contact
        -------
        I'm sure there are mistakes in my code or documentation. If you find any, please submit a [pull request]() or email me at: me@kevinformatics.com.

        Markdown Stylesheet
        -------------------
        The CSS used to style the the resultant HTML is originally from Github, but sourced from Andy Ferra (https://gist.github.com/andyferra/2554919).
        """
