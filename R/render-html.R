#' Return the HTML of the javascript-rendered page.
#'
#' Similar (i.e. a dynamic equivalent) to `rvest::read_html`.
#'
#' @md
#' @param splash_obj Object created by a call to [splash()]
#' @param url The URL to render (required)
#' @param base_url The base url to render the page with.
#' @param timeout A timeout (in seconds) for the render (defaults to 30). Without
#'        reconfiguring the startup parameters of the Splash server (not this package)
#'        the maximum allowed value for the timeout is 60 seconds.
#' @param resource_timeout A timeout (in seconds) for individual network requests.
#' @param wait Time (in seconds) to wait for updates after page is loaded (defaults to 0).
#' @param proxy Proxy profile name or proxy URL.
#' @param js Javascript profile name.
#' @param js_src JavaScript code to be executed in page context.
#' @param filters Comma-separated list of request filter names.
#' @param allowed_domains Comma-separated list of allowed domain names. If present, Splash
#'        won’t load anything neither from domains not in this list nor from subdomains of
#'        domains not in this list.
#' @param allowed_content_types Comma-separated list of allowed content types. If present,
#'        Splash will abort any request if the response’s content type doesn’t match any of
#'        the content types in this list. Wildcards are supported.
#' @param forbidden_content_types Comma-separated list of forbidden content types. If
#'        present, Splash will abort any request if the response’s content type matches
#'        any of the content types in this list. Wildcards are supported.
#' @param viewport View width and height (in pixels) of the browser viewport to render the
#'        web page. Format is “<width>x<height>”, e.g. 800x600. Default value is "full".
#' @param images Whether to download images.
#' @param headers HTTP headers to set for the first outgoing request.
#' @param body Body of HTTP POST request to be sent if method is POST.
#' @param http_method HTTP method of outgoing Splash request.
#' @param save_args A list of argument names to put in cache.
#' @param load_args Parameter values to load from cache
#' @param raw_html if `TRUE` then return a character vector vs an XML document. Only valid for `render_html`
#' @family splash_renderers
#' @return An XML document. Note that this is processed by [xml2::read_html()] so it will not be
#'         the pristine, raw, rendered HTML from the site. Use `raw_html=TRUE` if you do not want it
#'         to be processed first by `xml2`. If you choose `raw_html=TRUE` you'll get back a
#'         character vector.
#' @references [Splash docs](http://splash.readthedocs.io/en/stable/index.html)
#' @export
render_html <- function(splash_obj = splash_local, url, base_url, timeout=30, resource_timeout, wait=0,
                        proxy, js, js_src, filters, allowed_domains, allowed_content_types,
                        forbidden_content_types, viewport="1024x768", images, headers, body,
                        http_method, save_args, load_args, raw_html=FALSE) {

  wait <- check_wait(wait)

  params <- list(url=url, timeout=timeout, wait=wait, viewport=jsonlite::unbox(viewport))

  if (!missing(base_url)) params$base_url <- jsonlite::unbox(base_url)
  if (!missing(resource_timeout)) params$resource_timeout <- resource_timeout
  if (!missing(proxy)) params$proxy <- jsonlite::unbox(proxy)
  if (!missing(js)) params$js <- jsonlite::unbox(js)
  if (!missing(js_src)) params$js_src <- jsonlite::unbox(js_src)
  if (!missing(filters)) params$filters <- jsonlite::unbox(filters)
  if (!missing(allowed_domains)) params$allowed_domains <- jsonlite::unbox(allowed_domains)
  if (!missing(allowed_content_types)) params$allowed_content_types <- jsonlite::unbox(allowed_content_types)
  if (!missing(forbidden_content_types)) params$forbidden_content_types <- jsonlite::unbox(forbidden_content_types)
  if (!missing(images)) params$images <- as.numeric(images)
  if (!missing(headers)) params$headers <- headers
  if (!missing(body)) params$body <- jsonlite::unbox(body)
  if (!missing(http_method)) params$http_method <- jsonlite::unbox(http_method)
  if (!missing(save_args)) params$save_args <- jsonlite::unbox(save_args)
  if (!missing(load_args)) params$load_args <- jsonlite::unbox(load_args)

  if (is.null(splash_obj$user)) {
    res <- httr::GET(splash_url(splash_obj), path="render.html", encode="json", query=params)
  } else {
    res <- httr::GET(
      splash_url(splash_obj), path="render.html", encode="json", query=params,
      httr::authenticate(splash_obj$user, splash_obj$pass)
    )
  }

  httr::stop_for_status(res)

  out <- httr::content(res, as="text", encoding="UTF-8")

  if (!raw_html) out <- xml2::read_html(out)

  out

}